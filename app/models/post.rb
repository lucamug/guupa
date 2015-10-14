class Post < ActiveRecord::Base
  has_paper_trail :ignore => [:count_views, :count_children, :count_vote_1, :count_vote_2, :count_vote_3, :count_vote_4]  
  validates_presence_of :title
  validates_presence_of :description
  # validates_presence_of :map_data
  email_regex    = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :temporary_email, 
    :format      => {:with => email_regex },
    :allow_blank => true
  belongs_to :user
  has_many :attachments, :as => :attachable
  has_many :votes,       :as => :votable
  has_many :comments,    :as => :commentable
  has_many :taggings,    :as => :taggable
  has_many :received_messages, :class_name => "Message", :as => :recipient
  has_many :tags,        :through => :taggings

  has_many :children, :class_name => "Post", :foreign_key => 'post_id'
  belongs_to :father, :class_name => "Post", :foreign_key => 'post_id'

  attr_accessor :tag_names, :temporary_email
  attr_reader :old_tags, :old_status

  before_validation :if_editable_process_area_tag_and_tags_inside_tag_names_field
  after_validation  :if_editable_store_errors_and_update_status # Changes of status need to go before the tags_counting
  after_save :if_editable_update_taggings 
  after_save :if_editable_not_worning
  after_save :if_editable_handle_attachments_removal
  after_save :if_editable_tags_counting
  after_save :update_count_children
  
  def update_count_children
    # Refreshing the children counter of the father, if it exsist.
    if father = self.father
      father.count_children = father.children.visible.size
      father.save
    end
  end

  # Tag ID = 2, closed
  # Tag ID = 3, open
  def closed?
    if self.taggings.where(:tag_id => 2).first
      return true
    else
      return false
    end
  end
  def open?
    return ! self.closed?
  end

  def close
    if t = self.taggings.where("tag_id = ? or tag_id = ?", 2, 3).first
      t.tag_id = 2
      t.save
    else
      t = self.taggings.new(:tag_id => 2)
      self.sync_tagging(t)
      t.save!
    end  
  end

  def open
    if t = self.taggings.where("tag_id = ? or tag_id = ?", 2, 3).first
      t.tag_id = 3
      t.save
    else
      t = self.taggings.new(:tag_id => 3)
      self.sync_tagging(t)
      t.save!
    end  
  end

  scope :visible, lambda { where('status = ? or status = ?', :NEW, :APPROVED) } 
  self.per_page = 10
  #
  # About EDITING a POST
  #
  # Flow:
  #
  # 0 prepare_for_editing
  #    0.1 default_values
  #         Load defoult values (zero for all counters) in case fields are undefined
  #    0.2 backup_current_status_and_tags
  #         Load and save a copy of all the tags in @old_tags and the status in @old_status
  #    0.3 bring_tags_inside_tag_names_field
  #         Bring the translated version of the tag, comma separated, into the 
  #         "tag_names" field.
  #
  # ...NOW FIELDS CAN BE ASSIGNED TO NEW VALUES...
  #
  # BEFORE VALIDATION
  #
  # 1 if_editable_process_area_tag_and_tags_inside_tag_names_field
  #   1.1 process_data_from_map_api
  #        Process the data in "map_api" as it is coming from the form. It translated
  #        the content of this field into a list of tags. It returns an array of Tag
  #        object. "map_apy" could also be blank, in this case everything ramain as
  #        it was before, or "REMOVE", in this case the previous tags will be removed.
  #        In the future one post may be connected to more than one location. In
  #        that case I guess something need to be done here.
  #   1.2 process_tags_from_user
  #        Precess the tags that user edited comma separated. It return an array of
  #        Tag object as above. If the tags do not exsits they are created in the
  #        proper language depending of the user language.
  #
  # AFTER VALIDATION
  #
  # 2 if_editable_store_errors_and_update_status
  #       Check the presence of errors after the validation. If there were errors
  #       these are saved in "errors_list" and the status change to ERROR
  #
  # AFTER SAVE
  #
  # 3 if_editable_update_taggings
  #       Update the taggings of the post in case the visibility change.
  #
  # 4 if_editable_not_worning
  #       Just a worning in case the post is saved without following this procedure
  #
  # 5 if_editable_handle_attachments_removal
  #       Remove attachments in case the user asked.
  #
  # 6 if_editable_tags_counting
  #       Disabled? Why?
  #
  
  def is_idea?
    Util.my_log "\nPost: is_idea? DEPRECATED, use sub_type called by #{caller[0]}"
    return sub_type == :idea
  end

  def is_problem?
    Util.my_log "\nPost: is_problem? DEPRECATED, use sub_type called by #{caller[0]}"
    return sub_type == :problem
  end
  
  def sub_type
    if self.post_id == nil
      return :problem
    else
      return :idea
    end
  end

  def old_visible?
    return visibility_test?(self.old_status)
  end

  def visible?
    return visibility_test?(self.status)
  end
  
  def visibility_test?(local_status)
    if local_status == "NEW" or local_status == "APPROVED"
      return true
    else
      return false
    end
  end

  def translated_title(p = {})
    p[:l] ||= I18n.locale
    languages_by_lang = {}
    # Next line need to be removed once all the languages will ne in square brackets
    languages_by_lang[:en] = self.title.scan(/^(.*?)(\[\[|$)/)[0][0]
    scanned = self.title.scan(/\[\[(..)\:(.*?)\]\]/)
    if scanned.size > 0
      scanned.each do |s|
        # Util.my_log("#{s.inspect}")
        languages_by_lang[s[0].to_sym] = s[1]
      end
    end
    if languages_by_lang.has_key?(p[:l])
      return languages_by_lang[p[:l]]
    else
      return languages_by_lang[languages_by_lang.keys[0]]
    end
  end

  def self.current_website_id=(website_id)
    @current_website_id = website_id
  end

  def self.current_website_id
    @current_website_id ||= 0
  end

  def editable?
    if @editable
      return true
    else
      return false
    end
  end

  def prepare_for_editing
    self.default_values
    @editable = true
    unless new_record?
      # If this is a new record, no need to save status...
      self.backup_current_status_and_tags
      self.bring_tags_inside_tag_names_field
    end
  end

  def default_values
    # Util.my_log "\nPost: default_values: called by #{caller[0]}"
    self.count_views     ||= 0
    self.count_vote_1    ||= 0
    self.count_vote_2    ||= 0
    self.count_vote_3    ||= 0
    self.count_vote_4    ||= 0
    self.count_children  ||= 0
    self.website_id      ||= self.class.current_website_id
    self.status          ||= "NEVER_SAVED"
  end  

  def backup_current_status_and_tags
    # This function will generate sql queries for the tags, call it only if necessary
    # For the status I could use the dirty stuff as per 
    # http://stackoverflow.com/questions/5501334/how-to-properly-handle-changed-attributes-in-a-rails-before-save-hook
    # But for the relationships I need the plug in
    # http://stackoverflow.com/questions/5501334/how-to-properly-handle-changed-attributes-in-a-rails-before-save-hook
    # so I made it both by myself.    
    Util.my_log "\nPost: backup_current_status_and_tags: called by #{caller[0]}"
    @old_tags = []
    self.tags.each do |tag|
      @old_tags.push(tag)
    end
    @old_status = self.status
  end

  def bring_tags_inside_tag_names_field
    Util.my_log "\nPost: bring_tags_inside_tag_names_field: called by #{caller[0]}"
    self.tag_names = self.tags.where(:level => nil).map {|element| element.translated}.join(", ")
  end

  def sync_tagging(tagging)
    tagging.taggable_website_id       = self.website_id
    tagging.taggable_visible          = self.visible?
    tagging.taggable_is_a_father      = self.post_id.blank?
    tagging.tag_visible               = tagging.tag.visible?
    tagging.tag_child_of_tag_id       = tagging.tag.child_of_tag_id
  end

  def if_editable_update_taggings
    if self.editable?
      self.taggings.each do |tagging|
        self.sync_tagging(tagging)
        tagging.save!
      end
    end
  end  

  def if_editable_not_worning
    unless self.editable?
      Util.my_log "\nPost: Worning. Item saved without being prepared to save..."
      Util.my_log "Post: risk of altering the counter if the status change or tags change"
    end
  end
      
  def if_editable_tags_counting
    return # Disabled? Why?
    if self.editable?
      Util.my_log "\nPost: tags_counting: called by #{caller[0]}"
      # Here I should consider if the post has ERROR os has been REMOVE. In that
      # case I should not count the tags. That complicate the matter because I should
      # also pay attention when the post goes from ERROR to NEW, for example, to 
      # add the tags again.
      # Array math: http://www.ruby-doc.org/core/classes/Array.html
      if self.old_visible? and !self.visible?
        Util.my_log("Post: tags_counting: From visible to invisible, De-count old tags, ignore new ones")
        Counter.count(:my_tags => self.old_tags, :points => -1, :website_id => self.class.current_website_id)
      elsif !self.old_visible? and self.visible?
        Util.my_log("Post: tags_counting: From invisible to visible, Count new tags, Ignore the old ones")
        Counter.count(:my_tags => self.tags, :points => 1, :website_id => self.class.current_website_id)
      elsif self.visible?
        Util.my_log("Post: tags_counting: Both visible, De-count old tags, Count new tags")
        # Decount removed tags
        Counter.count(:my_tags => self.old_tags, :points => -1, :website_id => self.class.current_website_id)
        # Count added tags
        Counter.count(:my_tags => self.tags, :points => 1, :website_id => self.class.current_website_id)
      else
        Util.my_log("Post: tags_counting: Both invisible, Nothing to do")
      end
      self.backup_current_status_and_tags
    end
  end

  def tag_names_comma_separated
    result = []
    self.tags.each do |tag|
      if tag.level.blank?
        result.push(tag.translated)
      end
    end
    return result.join(", ")
  end

  def self.ids_that_have_all_these_tags(tags_ids)
    # This is a very delicate part where the filter is appied to the entire set of isses
    # It could create problem of performances so it may need some rethinking.
    # Now it quesry the database for each tag in the filter and retrieve the list of Post
    # ids (also of the Post that has been deleted or removed).
    # After it instersect all the results and it query the database again to extrat the
    # Post with the right order and removing Posts that has been deleted.
    # It may worthwhile to investigate into the plugin https://github.com/mbleigh/acts-as-taggable-on
    # The problem is that now tags is a polyphormic associations with other tables too
    # (Ideas, Attachments) also if not used.
    # For other documentation about query on Rails:
    # About Include
    #   http://snippets.dzone.com/posts/show/2089
    # For advanced query
    #   http://asciicasts.com/episodes/202-active-record-queries-in-rails-3
    #   http://asciicasts.com/episodes/215-advanced-queries-in-rails-3
    # For scopes
    #   http://edgerails.info/articles/what-s-new-in-edge-rails/2010/02/23/the-skinny-on-scopes-formerly-named-scope/index.html
    result = nil
    tags_ids.each do |id|
      r = ActiveRecord::Base.connection.select_all("SELECT taggable_id FROM taggings WHERE (tag_id = #{id} and taggable_type = 'Post')")
      if result
        result = result & r.map {|element| element["taggable_id"]}
      else
        result = r.map {|element| element["taggable_id"]}
      end
    end
    return result
  end

  def new_attachment_attributes=(attributes)
    # For this section, see http://asciicasts.com/episodes/134-paperclip
    attributes.each do |attribute|
      self.attachments.build(attribute)
    end
  end

  def existing_attachment_attributes=(attributes)
    # For this section, see http://asciicasts.com/episodes/134-paperclip
    # This part is for removing attachments. Has been moved out from this
    # method and put in the method "handle_attachments_removal" because
    # from there was not saving properly. This in case the post would not
    # pass the validation. Not sure why this is appening
    @existing_attachment_attributes = attributes
  end

  def if_editable_handle_attachments_removal
    if self.editable?
      # See method "existing_attachment_attributes=" for explanation
      if @existing_attachment_attributes
        @existing_attachment_attributes.each_key do |key|
          if @existing_attachment_attributes[key][:remove].to_i == 1
            # Request to remove this attachment
            attachment = self.attachments.find(key)
            attachment.status = "REMOVED"
            attachment.save
          end
        end
      end
    end
  end    

  def without_errors?
    if self.status and self.status == "ERROR"
      return false
    else
      return true
    end
  end

  def if_editable_store_errors_and_update_status
    if self.editable?
      # Here I will handle also three changes of status automatically:
      # "" => NEW
      # ERROR => NEW
      # anything => ERROR
      if self.errors.any?
        self.status = "ERROR"
        self.errors_list = self.errors.full_messages.join(", ")
      elsif self.old_status == "ERROR" or self.status == "NEVER_SAVED"
        self.status = "NEW"
        self.errors_list = ""
      end
    end
  end
    
  def my_validate
    @my_errors = nil
    if self.title.blank?
      self.status = "ERROR"
      @my_errors = [] unless @my_errors
      @my_errors.push("title cannot be blank")
    end
    if @my_errors
      self.errors_list = @my_errors.join(", ")
    end
    return @my_errors
  end

  def my_save
    if self.save and without_errors?
      return true
    else
      return false
    end
  end

  def my_update_attributes(param)
    if self.update_attributes(param) and without_errors?
      return true
    else
      return false
    end
  end

  def static_map
    config_decimals          = 1000000
    config_marker            = "markers=size:tiny|color:yellow|" # tiny|small|mid|large
    config_map_x             = "120"
    config_map_y             = "90"
    config_other_paramenters = "&sensor=false&language=#{I18n.locale}"
    config_map_type          = "&maptype=terrain"  # map|terrain|satellite
    config_google_url        = "http://maps.googleapis.com/maps/api/staticmap?"

    lat = self.map_lat.to_f/config_decimals
    lng = self.map_lng.to_f/config_decimals

    url    = "#{config_google_url}"
    url   += "size=#{config_map_x}x#{config_map_y}"
    url   += "#{config_other_paramenters}"
    url   += "#{config_map_type}"
    url   += "&#{config_marker}#{lat},#{lng}"
    url   += "&zoom=13"

    return url
  end

  def static_google_map_v2
    if @static_google_map || self.map_lat.blank? || self.map_lng.blank?
      return @static_google_map
    elsif self.map_lat and self.map_lng
      @static_google_map = []
      config_decimals          = 1000000
      config_strong_path       = "path=color:0xff00ffee|weight:1|"
      config_weak_path         = "path=color:0xff00ff55|weight:1|"
      config_marker_tiny       = "markers=size:tiny|color:yellow|"
      config_marker_small      = "markers=size:small|color:yellow|"
      config_marker_mid        = "markers=size:mid|color:yellow|"
      config_marker_large      = "markers=color:yellow|"
      # config_map_x             = "130"
      # config_map_y             = "160"
      config_map_x             = "180"
      config_map_y             = "180"
      config_map_x_large       = "640"  # 900
      config_map_y_large       = "640"  # 675
      config_other_paramenters = "&sensor=false&language=#{I18n.locale}"
      config_map_type          = "&maptype=map"
      config_terrain_type      = "&maptype=terrain"
      config_satellite_type    = "&maptype=satellite"
      config_google_url        = "http://maps.googleapis.com/maps/api/staticmap?"

      lat = self.map_lat.to_f/config_decimals
      lng = self.map_lng.to_f/config_decimals

      marker_large  = "#{config_marker_large}#{lat},#{lng}"
      marker_small = "#{config_marker_small}#{lat},#{lng}"

      if tag_level_5 = self.tags.find_by_level(5)
        # Municipality Map
        url    = "#{config_google_url}"
        url   += "size=#{config_map_x}x#{config_map_y}"
        url   += "&#{config_strong_path}#{tag_level_5.path_for_static_maps}"
        url   += "#{config_other_paramenters}"
        url   += "#{config_map_type}"
        url2 = url.gsub("#{config_map_x}x#{config_map_y}", "#{config_map_x_large}x#{config_map_y_large}")
        url   += "&#{marker_small}"
        url2  += "&#{marker_small}"
        # url2  += "&scale=2"
        @static_google_map.push([url, url2])
      end

      url    = "#{config_google_url}"
      url   += "size=#{config_map_x}x#{config_map_y}"
      url   += "#{config_other_paramenters}"
      url   += "#{config_map_type}"
      url   += "&zoom=16"
      url   += "&#{marker_small}"
      url2 = url.gsub("#{config_map_x}x#{config_map_y}", "#{config_map_x_large}x#{config_map_y_large}")
      url2.gsub!("zoom=16", "zoom=17")
      # url2  += "&scale=2"
      @static_google_map.push([url, url2])

      url    = "#{config_google_url}"
      url   += "size=#{config_map_x}x#{config_map_y}"
      url   += "#{config_other_paramenters}"
      url   += "#{config_satellite_type}"
      url   += "&zoom=19"
      url   += "&#{marker_small}"
      url2 = url.gsub("#{config_map_x}x#{config_map_y}", "#{config_map_x_large}x#{config_map_y_large}")
      url2.gsub!("zoom=19", "zoom=20")
      # url2  += "&scale=2"
      @static_google_map.push([url, url2])


    end
  end

  def static_google_map
    if @static_google_map
      return @static_google_map
    elsif self.map_lat and self.map_lng
      @static_google_map = {}
      config_decimals          = 1000000
      config_strong_path       = "path=color:0xff00ffee|weight:1|"
      config_weak_path         = "path=color:0xff00ff55|weight:1|"
      config_marker_tiny       = "markers=size:tiny|color:yellow|"
      config_marker_medium     = "markers=size:small|color:yellow|markers=color:yellow|"
      config_map_x             = "130"
      config_map_y             = "160"
      config_other_paramenters = "&maptype=terrain&sensor=false&language=#{I18n.locale}"
      config_google_url        = "http://maps.googleapis.com/maps/api/staticmap?"

      lat = self.map_lat.to_f/config_decimals
      lng = self.map_lng.to_f/config_decimals

      marker_tiny   = "#{config_marker_tiny}#{lat},#{lng}"
      marker_medium = "#{config_marker_medium}#{lat},#{lng}"

      tags_by_level = {}

      self.tags.each do |tag|
        tags_by_level[tag.level.to_i] = tag if tag.level
      end

      # World Map
      @static_google_map[0] = {}
      path_2 = ""
      if tags_by_level.has_key?(2) and tags_by_level[2].path_for_static_maps # Country
        path_2 = "&" + config_strong_path + tags_by_level[2].path_for_static_maps
      end
      @static_google_map[0][:title] = "World"
      @static_google_map[0][:url]   = "#{config_google_url}size=256x#{config_map_y}#{path_2}&center=30,0&zoom=0#{config_other_paramenters}"

      # Country Map
      if !path_2.blank?
        @static_google_map[2] = {}
        path_2.sub(config_strong_path, config_weak_path)
        if tags_by_level.has_key?(3) and tags_by_level[3].path_for_static_maps # Region
          path_3 = "&" + config_strong_path + tags_by_level[3].path_for_static_maps
        end
        @static_google_map[2][:title] = tags_by_level[2].translated
        @static_google_map[2][:url]   = "#{config_google_url}size=#{config_map_x}x#{config_map_y}#{path_2}#{path_3}#{config_other_paramenters}"
      end

      # Region Map
      if !path_3.blank?
        @static_google_map[3] = {}
        path_3.sub(config_strong_path, config_weak_path)
        if tags_by_level.has_key?(5) and tags_by_level[5].path_for_static_maps # Municipality
          path_5 = "&" + config_strong_path + tags_by_level[5].path_for_static_maps
        end
        @static_google_map[3][:title] = tags_by_level[3].translated
        @static_google_map[3][:url]   = "#{config_google_url}size=#{config_map_x}x#{config_map_y}#{path_3}#{path_5}#{config_other_paramenters}"
      end

      # Municipality Map
      if !path_5.blank?
        @static_google_map[5] = {}
        path_5.sub(config_strong_path, config_weak_path)
        @static_google_map[5][:title] = tags_by_level[5].translated
        @static_google_map[5][:url]   = "#{config_google_url}size=#{config_map_x}x#{config_map_y}#{path_5}#{config_other_paramenters}"
      end

      @static_google_map[6] = {} 
      @static_google_map[6][:title] = "not sure"
      @static_google_map[6][:url]   = "#{config_google_url}#{marker_medium}&size=150x160&maptype=satellite&sensor=false&language=#{I18n.locale}"
    else
      return nil
    end
    return @static_google_map
  end

  private

  def self.find_by_area_id(area)
    # This is used by the map, for the moment...
    posts = []
    if area.id == 1
      # Case of world, all posts are included because they don't have direct
      # relationship. This part need to be fixed later.
      posts = posts = Post.select("map_lat, map_lng, posts.id")
    else
      posts = area.posts.select("map_lat, map_lng, posts.id")
    end    
    result = []
    posts.each do |post|
      # Carefult here for html injections. This text is going to be html
      result.push([(post.map_lat/100).to_i, (post.map_lng/100).to_i, post.id])
    end
    return result
  end

  def process_tags_from_user
    return [] if self.tag_names.blank?
    tags = []
    tag_names.split(/\s*,\s*/).each do |name|
      Util.my_log("Post: ########### Working on #{name}")
      clean_name = Util.text_cleaner(name).downcase
      if tag = Tag.find_by_clean_name(clean_name)
        Util.my_log("Post: ########### #{name} found!")
        tag = tag.master if tag.master
        tags.push(tag)
      else
        Util.my_log("Post: ########### #{name} NOT found!")
        tag = Tag.new
        tag.name = name
        tag.clean_name = clean_name
        if I18n.locale != :en
          # User is browsing using a language different from English
          # in this case I will create two tags, one for english with clean
          # name = "it:italian_word" so that cannot be found, the other in
          # the proper language.
          tag_en = Tag.new
          tag_en.name = name
          tag_en.clean_name = "#{I18n.locale}:#{clean_name}"
          tag_en.save
          tags.push(tag_en)

          tag.translation_of_tag_id = tag_en.id
          tag.language = I18n.locale
          tag.save
        else
          tag.save
          tags.push(tag)
        end
      end
    end
    return tags
  end

  def if_editable_process_area_tag_and_tags_inside_tag_names_field
    if self.editable?
      tags_from_api = process_data_from_map_api
      tags_from_user = process_tags_from_user
      # uniq is to avoid that a post would be linked several times to the same tag
      self.tags = (tags_from_api + tags_from_user).uniq
    end
  end 
    
  def process_data_from_map_api
    from_map_api = {
      "c" => {},   # Country
      "3" => {},
      "4" => {},
      "5" => {},
      "b" => {},   # Bounds
      "z" => {},   # Zoom
      "lat" => {}, 
      "lng" => {},
      "a" => {}    # Address
    }
    if self.map_data == "REMOVE"
      # The user asked to remove the marker from the map. The post is not
      # yet localized
      self.map_bounds         = ""
      self.map_zoom           = ""
      self.map_lat            = ""
      self.map_lng            = ""
      self.map_address        = ""
    elsif self.map_data.blank?
      # Data from map has not be sent, so this means that the marker has not
      # moved or that the marker has not set at all.
      # If the marker was set previously, I should keep the tags as they are
      # but I don't have the bounds to re-create them again.
    else
      # This function is extracting data that was put together by the function
      # "codeLatLng" in "post_editing.js"
      self.map_data.split("; ").each do |item|
        (key, value) = item.split(":")
        from_map_api[key] = {}
        if the_match = /\((-{0,1}\d+ -{0,1}\d+ -{0,1}\d+ -{0,1}\d+)\)$/.match(value)
          from_map_api[key][:value] = the_match.pre_match
          from_map_api[key][:bounds] = the_match[1]
        else
          from_map_api[key][:value] = value
          from_map_api[key][:bounds] = nil
        end
      end
      level_2                 = from_map_api["c"]   ? from_map_api["c"][:value] : ""
      level_3                 = from_map_api["3"]   ? from_map_api["3"][:value] : ""
      level_4                 = from_map_api["4"]   ? from_map_api["4"][:value] : ""
      level_5                 = from_map_api["5"]   ? from_map_api["5"][:value] : ""
      self.map_bounds         = from_map_api["b"]   ? from_map_api["b"][:value] : ""
      self.map_zoom           = from_map_api["z"]   ? from_map_api["z"][:value] : ""
      self.map_lat            = from_map_api["lat"] ? from_map_api["lat"][:value] : ""
      self.map_lng            = from_map_api["lng"] ? from_map_api["lng"][:value] : ""
      self.map_address        = from_map_api["a"]   ? from_map_api["a"][:value] : ""

      # Next line is part of a procedure to avoid same name of items.
      if level_2 =~ /italy/i
        # In italy province and municipality may have the same name
        level_4 = "Province of #{level_4}" 
      end
      if level_2 =~ /japan/i
        if level_3 =~ /tokyo/i
          if level_4 =~ /Adachi|Arakawa|Bunkyo|Chiyoda|Chuo|Edogawa|Itabashi|Katsushika|Kita|Koto|Meguro|Minato|Nakano|Nerima|Ota|Setagaya|Shibuya|Shinagawa|Shinjuku|Suginami|Sumida|Taito|Toshima/i
            level_4 += "-ku"
          end
        end    
      end
      if level_2 =~ /panama/i
        level_3 = "#{level_3} Province" 
        level_5 = "#{level_3} City" if level_5 =~ /panama/i
      end
      if level_2 =~ /Luxembourg/i
        # Luxemburg is the name of a State, Disrict, Canton and City!
        level_3 = "#{level_3} District" 
        level_4 = "#{level_4} Canton"
        level_5 = "#{level_5} City" if level_5 =~ /Luxembourg/i
      end
      if level_2 =~ /Mozambique/i
        # There is a "locality" from google that enter at the 5th level... not sure why
        if level_5 =~ /Mozambique/i
          level_5 = "" 
        end
      end
      #if level_2 =~ /Puerto Rico/i
      #  # For the moment I will make Puerto Rico to belong to the USA as country
      #  # See http://geography.about.com/od/politicalgeography/a/puertoricoisnot.htm
      #  level_5 = level_4;    from_map_api["5"] = from_map_api["4"]
      #  level_4 = level_3;    from_map_api["4"] = from_map_api["3"]
      #  level_3 = level_2;    from_map_api["3"] = from_map_api["c"]
      #  level_2 = "United States"; from_map_api["c"][:bounds] = "18776300 170595700 71538800 -66885417"
      #end
      if level_2 =~ /Mexico/i and level_3 =~ /Mexico/i
        # Mexico has a state that is named Mexico, the same as the country!
        # See http://en.wikipedia.org/wiki/State_of_Mexico
        level_3 = "State of Mexico"
      end
      if level_2 =~ /Israel/i and level_3 =~ /Israel/i
        # Third level of Israel is always Israel, removing it...
        level_3 = level_4; from_map_api["3"] = from_map_api["4"]
        level_4 = level_5; from_map_api["4"] = from_map_api["5"]
        level_5 = ""; # Not sure what to do with from_map_api["5"]
      end
      if level_2 =~ /Vatican City/i and level_3 =~ /Vatican City/i
        # Same as Israel
        level_3 = level_4; from_map_api["3"] = from_map_api["4"]
        level_4 = level_5; from_map_api["4"] = from_map_api["5"]
        level_5 = ""; # Not sure what to do with from_map_api["5"]
      end
    end

    tags = []
    if tag_2 = load_or_create_this_area(level_2, 2, 1       , from_map_api["c"][:bounds], tags)       # Country
      if tag_3 = load_or_create_this_area(level_3, 3, tag_2.id, from_map_api["3"][:bounds], tags)     # Region
        if tag_4 = load_or_create_this_area(level_4, 4, tag_3.id, from_map_api["4"][:bounds], tags)   # Province
          if tag_5 = load_or_create_this_area(level_5, 5, tag_4.id, from_map_api["5"][:bounds], tags) # Municipality
          end
        end
      end
    end
    return tags
  end

  def load_or_create_this_area(name, level, father_id, bounds, tags)


    return nil if name.blank?
    bounds = "-90000000 -180000000 90000000 180000000" if bounds.blank?
    clean_name = Util.text_cleaner(name).downcase
    tag = nil
    if level == 2
      # In case of a country, it ignore the father id
      tag = Tag.find_by_clean_name_and_level(clean_name, level)
    else level > 2
      tag = Tag.find_by_clean_name_and_level_and_child_of_tag_id(clean_name, level, father_id)
    end
    if tag
      Util.my_log("Post#load_or_create_this_area: Found the level #{level}! \"#{clean_name}!\"")
      # Found the level_3!
    else
      Util.my_log("Post#load_or_create_this_area: Creating the level #{level}! \"#{clean_name}\"")
      # check if already exsist some tag with same name
      tag = Tag.new
      if duplicated_tag = Tag.find_by_clean_name(clean_name)


# raise "CiAo"



        # tag.save
        random = SecureRandom.base64.tr('+/', '-_')
        name += " (#{duplicated_tag.id.to_s}_#{SecureRandom.hex(2)})"
        # duplicated_tag.name = duplicated_tag.name + " (#{duplicated_tag.id.to_s})"
        # duplicated_tag.save
      end
      tag.name = name
      tag.clean_name = Util.text_cleaner(name).downcase
      tag.level = level
      tag.bounds = bounds
      tag.child_of_tag_id = father_id
      tag.save
    end
    tags.push(tag)
    return tag
  end

end

