module ApplicationHelper
  def aaaaaaaaaaaaaaaaaaaacapitalize_url(text)
    c = 0; 
    # Add in the next line other English preposition that don't need to
    # be capitalize when in the middle of the sentence.
    return text.split(/ |_/).map {|w| c = c + 1; (w =~ /^(of|the)$/ and c != 1) ? w : w.capitalize}.join('_')
  end
  
  def title
    return current_area_obj.translated
    # controller = params[:controller]
    # if controller == "items"
    #   # Overwrite the controller in case this is an Item because
    #   # plymorphism
    #   request.fullpath =~ /\/([^\/]*)/
    #   controller = $1
    # end
    # return t("titles." + controller + "." + params[:action])
  end



  def new_link_to(text, parameters = {})
    # This function is to fix a probable bug in rails because it seems that
    # when new links are created with "link_to" not all the value in params
    # are used. For example, "area" is used, but "tag_1" not. With this
    # function I force to submit them all again. This proble was actually
    # solved with the "default_url_options" method in the application_controller.rb
    #
    # This function remain to handle tags
    #
    # Making a local copy of the list of tags id otherwise ruby always work by reference
    # Util.my_log("new_link_to START #{text} #{parameters.inspect}")
    Util.my_log("#### new_link_to #{text} #{parameters.inspect}") if parameters[:verbose]
    local_filter = []
    current_nongeo_filter_ids.each do |id|
      local_filter.push(id)
    end
    if parameters[:replace_filter_with]
      local_filter = parameters[:replace_filter_with]
    elsif parameters[:remove_tag_obj]
      id = parameters[:remove_tag_obj].id
      if local_filter.include? id
        local_filter.delete(id)
      else
        # The tag is already removed in the url
        return text
      end
    elsif parameters[:add_tag_obj]
      id = parameters[:add_tag_obj].id
      if local_filter.include? id
        # The tag is already in the url
        return text
      else
        local_filter.push(id)
      end  
    end

    controller = parameters[:controller] || params[:controller]
    action     = parameters[:action]     || params[:action]
    area       = parameters[:area]       || params[:area]
    website    = parameters[:website]    || params[:website]     || current_website_obj.translated
    if supported_cookies?
      l = parameters[:l]  # Language only come with parameters
    else
      l = parameters[:l] || params[:l] || I18n.locale
    end

    # This is to force using certain routes when there are tags
    if controller == "posts" and local_filter.size > 0
      action = "index_with_tags"
    end
    
    # This is to remove the "issue" in the url, in case there are no tags
    if controller == "posts" and action == "index" and local_filter.size == 0
      action = "index_with_tags"
    end

    tag_1 = nil
    tag_2 = nil
    tag_3 = nil
    tag_4 = nil

    if id = local_filter[0]
      tag_1 = Tag.my_find_by_id(id).translated.gsub(/\s/, "_")
    end
    if id = local_filter[1]
      tag_2 = Tag.my_find_by_id(id).translated.gsub(/\s/, "_")
    end
    if id = local_filter[2]
      tag_3 = Tag.my_find_by_id(id).translated.gsub(/\s/, "_")
    end
    if id = local_filter[3]
      tag_4 = Tag.my_find_by_id(id).translated.gsub(/\s/, "_")
    end
    new_par = {
      :website    => website.gsub(/\s/, "_"),
      :area       => area.gsub(/\s/, "_"),
      :tag_1      => tag_1,
      :tag_2      => tag_2,
      :tag_3      => tag_3,
      :tag_4      => tag_4,
      :l          => l,
      :controller => controller,
      :action     => action
    }
    link = link_to_unless_current(text, new_par)




# raise new_par.inspect + link.inspect if text =~ /senso/i




    # Util.my_log("new_link_to END #{link}")
    return link
  end

  def my_edit_path(item, other = {})
    send("edit_#{item.class.to_s.downcase}_path", item, other)
  end
  def hide_path(item, other = {})
    send("hide_#{item.class.to_s.downcase}_path", item, other)
  end

  def my_url_for(p = {})
    helper_name = ""
    if p.has_key?(:helper_name)
      helper_name = p[:helper_name]
    elsif p.has_key?(:model)
      class_name   = p[:model].to_s.downcase
      class_name_p = class_name.pluralize
      if p[:type] == :new
        helper_name = "new_"  + class_name   + "_path"
      else
        helper_name =           class_name_p + "_path"
      end
    elsif p.has_key?(:item)
      class_name   = p[:item].class.to_s.downcase
      if p[:type] == :edit
        helper_name = "edit_" + class_name   + "_path"
      else
        helper_name =           class_name   + "_path"
      end
    end
#    return helper_name
    send(helper_name, params[:area], p[:item])
    # case_path(params[:area], p[:item])
  end


  def google_analytics_js
"<script type='text/javascript'>
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-15483804-1']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
".html_safe
  end
end

