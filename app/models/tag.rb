class Tag < ActiveRecord::Base
  decimals = 1000000 # Number of decimals used to store lat and lng
  has_many   :taggings,    :dependent => :destroy
  has_many   :posts,       :through => :taggings, :source => :taggable, :source_type => "Post"
  has_many   :attachments, :through => :taggings, :source => :taggable, :source_type => "Attachment"

  belongs_to :parent,       :foreign_key => "child_of_tag_id",       :class_name => "Tag"
  belongs_to :master,       :foreign_key => "translation_of_tag_id", :class_name => "Tag"
  has_many   :children,     :foreign_key => "child_of_tag_id",       :class_name => "Tag"
  has_many   :translations, :foreign_key => "translation_of_tag_id", :class_name => "Tag"

  validates  :clean_name, :presence   => true,
                          :uniqueness => { :case_sensitive => false }

  
  @@CACHE_tags = {}

  def self.my_cache
    return @my_cache
  end
  def self.my_cache_initialize(name)
    @my_cache       ||= {}
    @my_cache[name] ||= {}
    @my_cache[name][:initialized_on] ||= Time.now
    @my_cache[name][:initialized_by] ||= caller[0]
    @my_cache[name][:memory_object]  ||= {}
    @my_cache[name][:last_access_on]   = Time.now
    @my_cache[name][:last_access_by]   = caller[0]
    return @my_cache[name][:memory_object]
  end
  def self.my_cache_reset(name)
    cache = self.my_cache_initialize(name)
    cache[:memory_object]  = {}
    cache[:reset_on]  = Time.now
    cache[:reset_by]  = caller[0]
    return cache
  end
  def self.my_cache_write(name, keys, value)
    cache = self.my_cache_initialize(name)
    local_keys = []; keys.map{|a| local_keys.push(a)}
    self.my_cache_write_recursive(local_keys, value, cache)
    return cache
  end
  def self.my_cache_write_recursive(keys, value, cache)
    key = keys.shift
    cache[key] ||= {}
    if keys.size == 0
      cache[key][:v] = value
    elsif keys.size > 0
      cache[key][:vs] ||= {}
      my_cache_write_recursive(keys, value, cache[key][:vs])
    end
  end
  def self.my_cache_read(name, keys)
    cache = self.my_cache_initialize(name)
    local_keys = []; keys.map{|a| local_keys.push(a)}
    self.my_cache_read_recursive(local_keys, cache)
  end
  def self.my_cache_read_recursive(keys, cache)
    key = keys.shift
    unless cache.has_key?(key)
      return nil
    end
    if keys.size == 0
      return cache[key][:v]
    elsif keys.size > 0
      my_cache_read_recursive(keys, cache[key][:vs])
    end
  end
  
  # after_initialize :default_values
  # def default_values
  #   self.status ||= "NEW"
  #   self.language ||= "en"
  #   self.main_translation ||= true # They are only main translation until manually this values will be changed
  # end  

  def self.current_website_id=(website_id);  @current_website_id = website_id end
  def self.current_website_id;               @current_website_id ||= 0        end

  def self.my_find_by_id(ids, p = {})
    # test: Tag.my_find_by_id( [1, 2], :verbose => true)
    # test: Tag.my_find_by_id( 1, :verbose => true)
    local_ids = ids
    local_ids = [ids] unless ids.class.to_s == "Array"
    result = []
    local_ids = local_ids.uniq.sort
    ids_not_found = []
    local_ids.each do |id|
      if tag = self.my_cache_read(:tags, [id])
        Util.my_log("Tag.my_find_by_id: Found the tag #{id} in the cache") if p[:verbose]
        result.push(tag)
      else
        ids_not_found.push(id)
      end
    end
    if ids_not_found.size > 0
      Tag.where(:id => ids_not_found).each do |tag|
        Util.my_log("Tag.my_find_by_id: Stored the tag #{tag.id} in the cache") if p[:verbose]
        self.my_cache_write(:tags, [tag.id], tag)
        result.push(tag)
      end
    end
    if ids.class.to_s == "Array"
      return result
    else
      return result[0]
    end
  end
        
  def self.my_find_by_dirty_name(dirty_texts, p = {})
    # test: Tag.my_find_by_dirty_name(["armenia","armenia","world","non so(4)"], :verbose => true)
    # Given an array of dirty tags, returns an array with clean tags
    Util.my_log "Tag#my_find_by_dirty_name: called by #{caller[0]}" if p[:verbose]
    return nil if dirty_texts.blank?
    result = []
    work_on = dirty_texts
    work_on = [dirty_texts] unless dirty_texts.class.to_s == "Array"
    work_on.each do |dirty_text|
      found = false
      if dirty_text.blank?
      else
        a = dirty_text.scan(/\((\d+)\)$/)
        if a.size > 0
          if tag = Tag.my_find_by_id(a[0][0])
            result.push(tag)
            found = true
            Util.my_log("\t my_find_by_dirty_name: Found by an hard coded id in parenthesis (#{a.inspect})") if p[:verbose]
          else
            Util.my_log("\t my_find_by_dirty_name: NOT Found by an hard coded id in parenthesis (#{a.inspect})") if p[:verbose]
          end
        end
        cleaned = Util.text_cleaner(dirty_text).downcase
        unless found
          if tag = Tag.find_by_clean_name(cleaned)
            Util.my_log("\t my_find_by_dirty_name: Found by clean name [#{cleaned}]") if p[:verbose]
            if tag.master
              Util.my_log("\t my_find_by_dirty_name: It was a translation, found the master '#{tag.name}'") if p[:verbose]
              result.push(tag.master)
              self.my_cache_write(:tags, [tag.master.id], tag.master)
            else
              result.push(tag)
              self.my_cache_write(:tags, [tag.id], tag)
            end
          else
            Util.my_log("\t my_find_by_dirty_name: Not Found by clean name #{@area_from_url_cleaned}") if p[:verbose]
          end
        end
      end
    end
    if dirty_texts.class.to_s == "String"
      return result[0]
    else
      return result.uniq
    end
  end

  def visible?
    return true
  end

  def my_find_ancestors(result = [])
    if parent = self.parent
      # Here I should cache this tag
      result.push(parent)
      parent.my_find_ancestors(result)
    end
    return result.reverse
  end


  def my_find_children
    # Here I should cache these tags
    self.children
  end

  def self.aaaaaaaaaaaaaaaaaaamy_find_translation(tags, l = I18n.locale)
    local_tags = tags
    local_tags = [tags] if tags.class.to_s != "Array"
    ids_not_found_in_the_cache = []
    local_tags.each do |tag|
      if tag.translation_of_tag_id.blank?
        if self.my_cache_read(:translations, [tag.id,l])
          # Already in the cache        
        else
          ids_not_found_in_the_cache.push(tag.id)
          # Writing a temporary translation, in case the real one is not found
          # self.my_cache_write(:translations, [tag.id,l], "en:#{tag.name}")    
          self.my_cache_write(:translations, [tag.id,l], "#{tag.name}")    
        end
      else
        # This is actually a translation already. I ignore this item...
      end
    end
    # Here I could optimize more removing translations that are already inside the chache
    if ids_not_found_in_the_cache.size > 0
      items = Tag.where(:translation_of_tag_id => ids_not_found_in_the_cache, :language => l).select("name, translation_of_tag_id")
      items.each do |item|
        self.my_cache_write(:translations, [item.translation_of_tag_id,l], item.name)    
      end
    end
    result = local_tags.map{|tag| self.my_cache_read(:translations, [tag.id,l])}
    result = result[0] if tags.class.to_s != "Array"
    return result
  end

  def self.name_for_url(name)
    # This is NOT DONE yet...
    return URI.escape(name.gsub(/^\[[^\]]+\]/, "").gsub(" ", "_"))
  end

  def self.name_for_display(name)
    # This is NOT DONE yet...
    return name.gsub(/^\[[^\]]+\]/, "").gsub(/\([^)]+\)$/, "")
  end

  
  def translated(l = I18n.locale)
    @translated ||= {}
    unless @translated[l]
      Util.my_log "Tag#translated: Calling translated method directly without preloading on tag '#{self.name}' language = #{l}!"
      if t = Tag.where(:translation_of_tag_id => self.id, :language => l).select("name").first
        @translated[l] = t.name
      else
        @translated[l] = self.name
      end
    end
    return @translated[l]
  end

  def aaaaa_translated_without_square_brackets(l = I18n.locale)
    Util.my_log "### DEPRECATED Tag#translated_without_square_brackets, use TAG#translated_for_display"
    return translated_for_display(l)
  end

  def self.remove_parentesis(text)
    text.gsub!(/^\[[^\]]+\]/ , "")
    text.gsub!( /\([^)]+\)$/, "")
    return text
  end


#  def self.preload_quantities(tags)
#    ids = []
#    tags.each do |tag|
#      # if @@CACHE_quantities.has_key?(tag.id)
#      if self.my_cache_read(:quantities, [tag.id])    
#        # Util.my_log("Tag: preloaded tag of #{tag.name}. Already translated, move on")
#      else
#        ids.push(tag.id)
#        # Default translation, in case nothing is found later
#        # @@CACHE_quantities[tag.id] = 0
#        self.my_cache_write(:quantities, [tag.id], 0)
#      end
#    end
#    # Here I could optimize more removing translations that are already inside the chache
#    if ids.size > 0
#      # Now is loading only first level, I need to add other levels...
#      items = Counter.where(:tag_1_id => ids, :tag_2_id => nil, :website_id => self.current_website_id).select("tag_1_id, quantity")
#      items.each do |item|
#        # @@CACHE_quantities[item.tag_1_id] = item.quantity
#        self.my_cache_write(:quantities, [item.tag_1_id], item.quantity)
#      end
#    end
#    return "ciao"
#  end


#  def self.my_cache_quantities(website, filter, result)
#    result.keys.each do |id|
#      Tag.my_cache_write(:quantities, [website, filter.join("_"), id], result[id])
#    end
#  end
#
#  def counted(filter = [])
#    return Tag.my_cache_read(:quantities, [filter.join("_"), self.id]) || 0
#  end

  def path_for_static_maps
    return "#{south_bound},#{west_bound}|#{north_bound},#{west_bound}|#{north_bound},#{east_bound}|#{south_bound},#{east_bound}|#{south_bound},#{west_bound}" if split_bounds
  end

  def south_bound
    return split_bounds[:s] if split_bounds
  end
  def west_bound
    return split_bounds[:w] if split_bounds
  end
  def north_bound
    return split_bounds[:n] if split_bounds
  end
  def east_bound
    return split_bounds[:e] if split_bounds
  end

#  -path = "color:0xff00ffcc|weight:1|#{s},#{w}|#{n},#{w}|#{n},#{e}|#{s},#{e}|#{s},#{w}"
    
  def self.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaid_equal(id)   
    find(1)
    where("tags.id = ?", id)
    #where("tags.level < ?", level)  
  end

  
  def self.aaaaaaaaaaaaaaaaaaaaaaaaaaaaacached_find(id)
    if @@CACHE_tags.has_key?(id)
      return @@CACHE_tags[id]
    else
      return @@CACHE_tags[id] = self.find(id)
    end
  end

  def aaaaaaaa_translation
    translations.where("language = ?", I18n.locale)  
  end

  private

  def split_bounds
    if self.bounds
      unless @splitted_bounds
        config_decimals = 1000000
        s = self.bounds.split(" ").map{|item| item.to_f/config_decimals}
        @splitted_bounds = {}
        @splitted_bounds[:s] = s[0]
        @splitted_bounds[:w] = s[1]
        @splitted_bounds[:n] = s[2]
        @splitted_bounds[:e] = s[3]
      end
      return @splitted_bounds
    else
      return nil
    end
  end

end

