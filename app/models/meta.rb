class Meta
  # This class execute advanced query to the database involving several
  # other models...

  def self.load_filtered_posts_ids(p = {})
    # This function is udes by:
    #
    #   load_filtered_posts (Ajax querying by the map)
    #   load_filtered_tags_and_posts
    #
    # Return filtered posts' ids using the table "taggings".
    #
    # INPUT: area_id, nongeo_filter_ids, website_id
    #
    # OUTPUT: array of posts' ids. nil if no filter (both nongeo and area,
    #         for example the home page)
    #
    # Already filter also based on website that is a redontant value in the
    # taggings table. I am not sure if this is necessary or not.
    #
    # TESTING:
    #
    # Meta.load_filtered_posts_ids(:nongeo_filter_ids => [Tag.find_by_name("cultural type").id], :area_id => Tag.find_by_name("Italy").id, :website_id => 1)
    # Meta.load_filtered_posts_ids(:area_id => Tag.find_by_name("Italy").id, :website_id => 1)
    # Meta.load_filtered_posts_ids(:website_id => 1) # Return "nil" because no filter!
    #
    p[:stopw].take_time("Meta#load_filtered_posts_ids...: START") if p[:stopw]
    p[:area_id]           ||= 1  # Area id is world by default
    p[:nongeo_filter_ids] ||= [] # Contain the id of tags in the filter
    p[:website_id]        ||= 0  # GuuPa main site0
    # Build an array of tags ids fo the filter excluded the world = 1
    geo_and_nongeo_filter_ids = [p[:area_id]] + p[:nongeo_filter_ids] - [1]
    result = nil
    if geo_and_nongeo_filter_ids.size > 0 # No filter (home page)
      geo_and_nongeo_filter_ids.each do |id|
        # Sub step: Looking for all post ids that pass the filter TAG BY TAG
        post_ids = Tagging.select(:taggable_id).where(:tag_id => id, :taggable_website_id => p[:website_id], :taggable_visible => true, :tag_visible => true, :taggable_is_a_father => true).map{|a| a.taggable_id}
        if result
          # Intersaction of the posts. To increase the performance could be useful
          # to start the intersaction from the smallest group of posts because
          # because interect large group take longer time.
          result = post_ids & result
        else
          result = post_ids
        end
      end
    else
      # No filter have been selected. This is the rare case of being in the page
      # "World" without any filter. I should query anyway posts based on website
      # and other things...
      result = Tagging.select(:taggable_id).where(:taggable_website_id => p[:website_id], :taggable_visible => true, :tag_visible => true, :taggable_is_a_father => true).map{|a| a.taggable_id}
    end
    return result
  end

  def self.load_user_posts(p = {})
    p[:stopw].take_time("Meta#load_user_posts...: START") if p[:stopw]
    p[:website_id]        ||= 0  # GuuPa main site
    p[:user_id]           ||= 0  # ???
    filtered_post_ids = Vote.where(:user_id => p[:user_id], :votable_type => "Post").map{|a| a.votable_id}
    posts = []
    posts = Post.select([:id, :map_lat, :map_lng]).where(:id => filtered_post_ids, :website_id => p[:website_id])
    result = []
    posts.each do |a|
      result.push [ (a.map_lat/100), (a.map_lng/100), a.id ]
    end
    return result
  end    

  def self.load_filtered_posts(p = {})
    # This generate the data for the ajax query fot the map in the user page.
    # If posts have not lat or lng they are skipped.
    # For testing
    #
    # Meta.load_filtered_posts(:nongeo_filter_ids => [Tag.find_by_name("cultural type").id], :area_id => Tag.find_by_name("Italy").id, :website_id => 1)
    # Meta.load_filtered_posts(:area_id => Tag.find_by_name("Italy").id, :website_id => 1)
    # Meta.load_filtered_posts(:website_id => 1)
    p[:stopw].take_time("Meta#load_filtered_posts...: START") if p[:stopw]
    p[:website_id]        ||= 0  # GuuPa main site
    p[:area_id]           ||= 1  # Area id is world by default
    p[:nongeo_filter_ids] ||= [] # Contain the id of tags in the filter
    filtered_post_ids = self.load_filtered_posts_ids(p)
    if filtered_post_ids
      posts = Post.select([:id, :map_lat, :map_lng]).where(:id => filtered_post_ids, :website_id => p[:website_id])
      # query = "SELECT id, gps_latitude, gps_longitude FROM posts WHERE id IN (#{filtered_post_ids.join ','})"
    else
      posts = Post.select([:id, :map_lat, :map_lng]).where(:website_id => p[:website_id]).visible
      # query = "SELECT id, gps_latitude, gps_longitude FROM posts"
    end
    result = []
    posts.each do |a|
      if a.map_lat.is_a?(Integer) and a.map_lng.is_a?(Integer)
        result.push [ (a.map_lat/100), (a.map_lng/100), a.id ]
      end
      # Here I may need to handle posts that don't have a vaild lat lng. For the moment
      # I just skip them
    end
    return result
  end      

  def self.load_filtered_tags_and_posts(p = {})
    #
    # This class method load all the data from the database that is necessary
    # for the home page, in the most efficent way, trying to cache things and
    # reduce the number of queries to the database.
    #
    # For testing
    #
    # Meta.load_filtered_tags_and_posts(:nongeo_filter_ids => [Tag.find_by_name("cultural type").id], :area_id => Tag.find_by_name("Italy").id, :website_id => 1)
    # Meta.load_filtered_tags_and_posts(:area_id => Tag.find_by_name("Italy").id)[:preloaded]
    # Meta.load_filtered_tags_and_posts
    # Meta.load_filtered_tags_and_posts(:website_id => 2, :l => :it)[:preloaded][:names]
    #
    ############    OUTPUT    #############
    #
    # :preloaded
    #
    #   :names           {1=>"Tag_1.1", 2=>"Tag_1.2", 3=>"Tag_2.1", 4=>"Tag_2.2", 5=>"Tag_3.1", 6=>"Tag_3.2"}
    #   :levels          {1=>nil, 2=>nil, 3=>nil, 4=>nil, 5=>nil, 6=>nil}
    #   :translations    {1=>nil, 2=>nil, 3=>nil, 4=>nil, 5=>nil, 6=>nil}
    #
    # :vote_objs_by_post_id        nil
    #
    # :attachment_objs_by_post_id  []
    #
    # :paged_post_objs             Array with the list of Posts in form of objects
    #
    # :ids_and_quantities
    #
    #   :quantity_by_tag_id        {1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 7=>1}
    #   :paged_post_ids            [1, 2]
    #   :quantity_tags             6
    #   :quantity_filtered_posts   2
    #   :filtered_post_ids         nil
    #   :tag_ids_from_paged_posts  [1, 2, 3, 4]
    #   :tag_ids_by_paged_posts    {1=>[1, 2], 2=>[3, 4]}
    #
    #######################################
    #
    #
    p[:stopw].take_time("Meta#load...: START") if p[:stopw]
    p[:nongeo_filter_ids] ||= [] # Contain the id of tags in the filter
    p[:area_id]           ||= 1  # Area id is world by default
    p[:website_id]        ||= 0  # GuuPa main site
    p[:page]              ||= 1
    p[:l]                 ||= I18n.locale
    p[:user_id]           ||= nil # Nil means that there are no users logged in
    p[:order]             ||= :created
    p[:direction]         ||= :natural
    order = ""
    if p[:order] == "views"
      order = "count_views "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    elsif p[:order] == "children"
      order = "count_children "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    elsif p[:order] == "vote_1"
      order = "count_vote_1 "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    elsif p[:order] == "vote_2"
      order = "count_vote_2 "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    elsif p[:order] == "vote_3"
      order = "count_vote_3 "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    elsif p[:order] == "vote_4"
      order = "count_vote_4 "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    else # Default ordering
      order = "created_at "
      order += p[:direction] == :natural ? "DESC" : "ASC"
    end
    ################
    ##   STEP 1   ##
    ################
    # Looking for all post ids that pass the filter unless is the home page.
    # If it is the home page I will take care later (return nil)
    # If no posts pass the filter, it is an empty array
    filtered_post_ids = self.load_filtered_posts_ids(p)
    p[:stopw].take_time("Meta#load...: STEP 1 Finished") if p[:stopw]
    ################
    ##   STEP 2   ##
    ################
    # Getting out all the tags of the previous selected posts and 
    # Counting them...
    # In case is the home page, getting all the tags without filtering on posts.
    # Tags should either have no parents (NONGEO TAG) or have the parent = currenta area
    query = ""
    taggings = nil
    if filtered_post_ids
      if filtered_post_ids.size > 0
        # The following could be a slow query because filtered_post_ids may reach
        # high numbers... several hunder thousands...
        # Add here the check on the visibility field
        taggings = Tagging.select(:tag_id).where(:taggable_website_id => p[:website_id]).where(:taggable_id => filtered_post_ids).where("tag_child_of_tag_id = ? OR tag_child_of_tag_id IS NULL", p[:area_id])
      else
        # Here I should consider the case where no posts pass the filter.
        # It is unlikely if user browse updated page but could happen if user
        # came back to the side with an old link and some post'tag has been
        # removed...
        taggings = []
      end
    else
      # Add here the check on the visibility field
      taggings = Tagging.select(:tag_id).where(:taggable_website_id => p[:website_id]).where("tag_child_of_tag_id = ? OR tag_child_of_tag_id IS NULL", p[:area_id])
    end
    # query += subquery unless subquery.blank?
    quantity_by_tag_id = {}
    taggings.each do |a|
      quantity_by_tag_id[a.tag_id] ||= 0
      quantity_by_tag_id[a.tag_id] += 1
    end
    # From quantities removing tags that are already in the filter
    # NOt sure why is this done?
    p[:nongeo_filter_ids].each do |id|
      quantity_by_tag_id.delete(id) if quantity_by_tag_id.has_key?(id)
    end
    p[:stopw].take_time("Meta#load...: STEP 2 Finished") if p[:stopw]
    ################
    ##   STEP 3   ##
    ################
    # Getting all the ids of post that are present in certain page (paged posts)
    # Then taking also all the tags ids of these posts.
    #
    paged_post_objs = []
    quantity_filtered_posts = nil
    unless filtered_post_ids
      # Home page, no filter

#      paged_post_objs = Post.page(p[:page]).visible.where(:website_id => p[:website_id]).order(order)
      paged_post_objs = Post.paginate(:page => p[:page]).visible.where(:website_id => p[:website_id]).order(order)
      quantity_filtered_posts = paged_post_objs.size
    else
#      paged_post_objs = Post.page(p[:page]).visible.where(:id => filtered_post_ids).order(order)
      paged_post_objs = Post.paginate(:page => p[:page]).visible.where(:id => filtered_post_ids).order(order)
      quantity_filtered_posts = filtered_post_ids.size
    end

# puts will_paginate(paged_post_objs)

    paged_post_ids = paged_post_objs.map{|post| post.id}
    # Now getting all the tags of the paged posts
    # query = "SELECT tag_id, taggable_id FROM taggings WHERE taggable_id IN (#{paged_post_ids.join ','})"
    taggings = Tagging.select([:tag_id, :taggable_id]).where(:taggable_id => paged_post_ids)
    tag_ids_from_paged_posts = []
    tag_ids_by_paged_posts = {}
    taggings.each do |a|
      tag_ids_from_paged_posts.push a.tag_id
      tag_ids_by_paged_posts[a.taggable_id] ||= []
      tag_ids_by_paged_posts[a.taggable_id].push a.tag_id
    end
    # Adding some other tag to the one that need to be preloaded.
    # I may need to add also ancesters of area.
    ids_to_preload = (quantity_by_tag_id.keys + tag_ids_from_paged_posts + [p[:area_id]] + p[:nongeo_filter_ids] + [1]).sort.uniq
    p[:stopw].take_time("Meta#load...: STEP 3 Finished") if p[:stopw]
    ################
    ##   STEP 4   ##
    ################
    #
    # Loading votes for the paged posts if the user is logged in
    # Testing:
    # Meta.load_filtered_tags_and_posts(:nongeo_filter_ids => [724, 505], :area_id => 83, :user_id => 1)
    # Meta.load_filtered_tags_and_posts(:user_id => 1)[:vote_objs_by_post_id]
    #
    vote_objs_by_post_id = nil
    if p[:user_id]
      vote_objs_by_post_id = {}
      Vote.where(:user_id => p[:user_id], :votable_id => paged_post_ids, :votable_type => :Post).each do |vote|
        vote_objs_by_post_id[vote.votable_id] = vote
      end
    end
    p[:stopw].take_time("Meta#load...: STEP 4 Finished") if p[:stopw]
    ################
    ##   STEP 4 bis   ##
    ################
    #
    # Loading virtual tags if user is logged in
    # Testing:
    # Meta.load_filtered_tags_and_posts(:nongeo_filter_ids => [724, 505], :area_id => 83, :user_id => 1)
    # Meta.load_filtered_tags_and_posts(:user_id => 1)[:vote_objs_by_post_id]
    #
    # 2200 will go
    # 2201 have been
    # 2202 dislike
    # 2203 like
    # 2204 user
    
    

    vote_objs_by_post_id = nil
    if p[:user_id]
      vote_objs_by_post_id = {}
      Vote.where(:user_id => p[:user_id], :votable_id => paged_post_ids, :votable_type => :Post).each do |vote|
        vote_objs_by_post_id[vote.votable_id] = vote
      end
    end
    p[:stopw].take_time("Meta#load...: STEP 4 Finished") if p[:stopw]
    ################
    ##   STEP 5   ##
    ################
    #
    # Loading attachments for the paged posts
    # Testing:
    # Meta.load_filtered_tags_and_posts[:attachment_objs_by_post_id]
    #
    attachment_objs_by_post_id = {}
    Attachment.where(:attachable_id => paged_post_ids, :attachable_type => :Post).each do |attachment|
      attachment_objs_by_post_id[attachment.attachable_id] ||= []
      attachment_objs_by_post_id[attachment.attachable_id].push(attachment)
      # attachment_objs_by_post_id[attachment.attachable_id] = attachment
    end
    p[:stopw].take_time("Meta#load...: STEP 5 Finished") if p[:stopw]
    ################
    ##   STEP 6   ##
    ################
    #
    # Preloading tags and translations
    #
    # 
    preloaded = self.preload_tags_and_translations(ids_to_preload, p[:l])
    p[:stopw].take_time("Meta#load...: STEP 6 Finished") if p[:stopw]
    ################
    ##   STEP 7   ##
    ################
    #
    # Storing the result
    #
    # 
    total = {
      :preloaded                  => preloaded,
      :vote_objs_by_post_id       => vote_objs_by_post_id,
      :attachment_objs_by_post_id => attachment_objs_by_post_id,
      :paged_post_objs            => paged_post_objs,
      :ids_and_quantities         => {
        :quantity_by_tag_id         => quantity_by_tag_id,
        :paged_post_ids             => paged_post_ids,
        :quantity_tags              => quantity_by_tag_id.keys.size,
        :quantity_filtered_posts    => quantity_filtered_posts,
        :filtered_post_ids          => filtered_post_ids,
        :tag_ids_from_paged_posts   => tag_ids_from_paged_posts,
        :tag_ids_by_paged_posts     => tag_ids_by_paged_posts,
      }
    }
    return total
  end


  def self.order_by(p = {})
    # This is used to order tags.
    #
    # tags_quantity contain list of tags and quantity as returned from Counter
    # Here I should group and order. Order within a group can be done by :alpha
    # or by :quantity
    #
    # For testing: Tag.order_by
    #    
    p[:l]               ||= I18n.locale
    p[:tags_quantities] ||= Counter.extract_ids_quantities
    p[:order_by]        ||= :quantity
    #p[:name_filter]     ||= //
    #p[:level_equal]     ||= 2
    p[:condition]       ||= "level == 2"
    p[:minus]           ||= []
    # Following command should be called somewhere else. Here I call again, just
    # in case  
    preloaded = Meta.preload_tags_and_translations p[:tags_quantities].keys, p[:l]
    # preload return something like {:names=>{1=>"World"}, :levels=>{1=>0}, :translations=>{1=>nil}}
    # For testing: Tag.preload_tags_and_translations Counter.extract_ids_quantities.keys
    by_order = {}
    ids = p[:tags_quantities].keys - p[:minus]
    ids.each do |id|
      name        = preloaded[:names][id]
      level       = preloaded[:levels][id]
      translation = preloaded[:translations][id] || name
      quantity    = p[:tags_quantities][id]
      # Util.my_log("Working on id=#{id} name=#{name} levels=#{level} translation=#{translation} quantity=#{quantity}")    
      if eval(p[:condition])
        # tag.clean_name.match(filter)
        key = ""
        if p[:order_by] == :alpha
          # key_1 is to sort alphabetical and then by quantity
          key = "#{translation.lstrip.ljust(6, "-")[0,6]}#{"%06d" % (999999 - quantity)}"
        else
          # key_1 is to sort by quantity and then alphabetical
          key = "#{"%06d" % (999999 - quantity)}#{translation.lstrip.ljust(6, "-")[0,6]}"
        end
        # Util.my_log("key=#{key} order_by=#{p[:order_by] == :alpha}")    
        by_order[key] ||= []
        by_order[key].push(id)
      end
    end
    result = {}
    by_order.keys.sort.each do |key|
      by_order[key].each do |id|
        result[id] = p[:tags_quantities][id]
      end
    end
    return result
  end

  def self.preload_tags_and_translations(tag_ids, l = I18n.locale)
    names        = Cache.get :preloaded_names
    levels       = Cache.get :preloaded_levels
    translations = Cache.get :preloaded_translations
    tag_ids_not_loaded_yet = tag_ids - names.keys
    if tag_ids_not_loaded_yet.size > 0
      Tag.where(:id => tag_ids_not_loaded_yet).select("id, name, level").each do |tag|
        names[tag.id]  = tag.name
        levels[tag.id] = tag.level
      end
    end
    translations[l] ||= {}
    translations_ids_not_loaded_yet = tag_ids - translations[l].keys
    if translations_ids_not_loaded_yet.size > 0
      Tag.where(:translation_of_tag_id => translations_ids_not_loaded_yet, :language => l).select("name, translation_of_tag_id").each do |tag|
        translations[l][tag.translation_of_tag_id] = tag.name
      end
      translations_ids_not_loaded_yet = tag_ids - translations[l].keys
      translations_ids_not_loaded_yet.each do |tag_id|
        translations[l][tag_id] = nil
      end
    end
    return {:names => names, :levels => levels, :translations => translations[l]}
  end
end
