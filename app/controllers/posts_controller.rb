class PostsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :vote
  def index
    if js_format
      data = Meta.load_filtered_posts(
        :website_id        => current_website_id,
        :area_id           => current_area_id,
        :nongeo_filter_ids => current_nongeo_filter_ids
      )
      #render "index"
      render :json => data
    else
      stopw.take_time("PostsController#index: START")
      @current_user               = current_user_id;            stopw.take_time("PostsController#index: After current_user                = #{@current_user}")
      @current_area_obj           = current_area_obj;           stopw.take_time("PostsController#index: After current_area_id             = #{@current_area_obj}")
      @current_area_id            = @current_area_obj.id
      @current_area_translated    = @current_area_obj.translated
      @current_area_ancestors_ids = current_area_ancestors_ids; stopw.take_time("PostsController#index: After current_area_ancestors_ids = #{@current_area_ancestors_ids}")
      @current_nongeo_filter_objs = current_nongeo_filter_objs
      @current_nongeo_filter_ids  = current_nongeo_filter_ids;  stopw.take_time("PostsController#index: After current_nongeo_filter_ids   = #{@current_nongeo_filter_ids}")

      @uri_current_area           = "/" + uri_escape(current_website_obj.translated) + "/" + uri_escape(Tag.name_for_url(@current_area_obj.translated))
      @uri_current_all            = "/" + uri_escape(current_website_obj.translated) + "/" + uri_escape(Tag.name_for_url(@current_area_obj.translated)) + @current_nongeo_filter_objs.map{|tag| "/" + Tag.name_for_url(tag.translated) }.join
      @uri_world                  = "/" + uri_escape(current_website_obj.translated) + "/" + uri_escape(world_translated)

      # Preparing metadata of the page
      title = current_website_obj.build_title(:current_area_obj => current_area_obj)
      @html_title = title[1]
      @html_title = @current_nongeo_filter_objs.map{|tag| "\"#{tag.translated}\""}.to_sentence + " #{t(:at)} " + @html_title if (@current_nongeo_filter_objs.size > 0)
      @html_content = t(:meta_content, :area => "#{title[2]} #{@current_area_translated}")
      url_with_language = "http://#{request.host_with_port}#{@uri_current_all}?l=#{I18n.locale}"
      @og             = {}
      @og[:type]      = "cause"
      @og[:url]       = url_with_language
      @og[:image]     = "http://#{request.host_with_port}" + ActionController::Base.helpers.image_path("guupa_logo_square.jpg")
      @og[:site_name] = "guupa.com"

      @facebook_after_body = facebook_after_body
      @facebook_button     = facebook_button(url_with_language)

      stopw.take_time("PostsController#index: After world_translated    = #{@uri_world_escaped}")

      ids_to_preload  = [@current_area_id]
      ids_to_preload += @current_area_ancestors_ids
      ids_to_preload += @current_nongeo_filter_ids

      everything = Meta.load_filtered_tags_and_posts(
        :nongeo_filter_ids => current_nongeo_filter_ids,
        :area_id           => current_area_id,
        :website_id        => current_website_id,
        :page              => current_page,
        :user_id           => current_user_id,
        :stopw             => stopw,
        :order             => params[:order_by]
      )
      stopw.take_time("PostsController#index: After Meta.load_everything")

      refine_your_filter = everything[:ids_and_quantities][:quantity_by_tag_id]
      @quantity          = everything[:ids_and_quantities][:quantity_filtered_posts]
      posts              = everything[:paged_post_objs]

      tag_groups = {}
      tag_groups[:geo_path]     = current_area_ancestors_ids + [current_area_id]
      tag_groups[:nongeo_path]  = current_nongeo_filter_ids
      @preloaded = everything[:preloaded]
      @refines = []
      if current_website_id == 2
        @refines.push :name => t(:open_closed), :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "id == 2 or id == 3")
        @refines.push :name => t(:by_tag),      :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "level.blank? and id != 2 and id != 3")
        sub_area_level = @current_area_obj.level + 1
        sub_area_level = 2 if @current_area_obj.level == 0 # The area level == 1 (Europe, Asia, etc.) does not exsists yet.
        @refines.push :name => t(:by_region),   :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "level == #{sub_area_level}")
      else
        @refines.push :name => t(:by_tag),      :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "(level.blank? and name !~ /\\./ and name !~ /\\d{4}/) and !name.blank?")
        @refines.push :name => t(:by_criteria), :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :alpha, :condition => "level.blank? and name =~ /\\./")
        if @current_area_obj.level == 0
          @refines.push :name => t(:by_country), :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "level == 2"                             )
        elsif @current_area_obj.level < 4
          @refines.push :name => t(:by_region), :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :quantity, :condition => "level == #{@current_area_obj.level + 1}"                             )
        end
        @refines.push :name => t(:by_year),    :data => (Meta.order_by :tags_quantities => refine_your_filter, :order_by => :alpha,    :condition => "level.blank? and name =~ /\\d\\d\\d\\d/")
      end
      stopw.take_time("PostsController#index: After ordering")
      stopw.take_time("PostsController#index: END")
      Util.my_log "PostsController#index: END"
      # render :text => "<xmp>#{current_area_obj.inspect}</xmp>"
      # render "index", :locals => {:tag_groups => tag_groups, :items => posts}, :layout => false
      render "index", :locals => {
        :tag_groups                 => tag_groups,
        :items                      => posts,
        :vote_objs_by_post_id       => everything[:vote_objs_by_post_id],
        :attachment_objs_by_post_id => everything[:attachment_objs_by_post_id],
        :tag_ids_by_paged_posts     => everything[:ids_and_quantities][:tag_ids_by_paged_posts],
      }
    end
  end

  def index_with_tags
    # This action is a trick to be able to generate proper url forcing
    # action = index_with_tags during index_wiindex creation. The behavior is
    # then exactly the same as index.
    index
  end

  def show_idea
    show
  end

  def show
    if @post.father # This is a children (idea, for example), I will load the father...
      @post = @post.father 
    end

    # Preparing metadata of the page
    level = ""
    if level = @post.tags.where(:level => 5).first
    elsif level = @post.tags.where(:level => 4).first
    elsif level = @post.tags.where(:level => 3).first
    elsif level = @post.tags.where(:level => 2).first
    end
    level ||= world_obj
    title = @post.title.gsub(/\s\.\s*$/, ".")
    content = @post.description
    content = ActionController::Base.helpers.sanitize(content, :tags => %w())
    content = content.gsub(/\n/," ").gsub(/^(.{200}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
    content = "#{t(:how_would_you_solve_this_issue, :area => Tag.name_for_display(level.translated))} #{content}"
    image_url = ""
    if @post.attachments.size > 0 && @post.attachments[0].document.file?
      image_url = "http://#{request.host_with_port}#{@post.attachments[0].document.url(:thumb)}"
    elsif url = @post.static_map
      image_url = url
    end
    url_with_low_level_and_language =  "#{ url_for({:id => @post.id, :area => level.translated.gsub(" ", "_"), :l => I18n.locale}) }"
    @html_title     = title
    @html_content   = content
    @og             = {}
    @og[:type]      = "cause"
    @og[:url]       = url_with_low_level_and_language
    @og[:image]     = image_url
    @og[:site_name] = "guupa.com"
    # @og[:site_name] = current_website_obj.build_title(:current_area_obj => level)[1]
    @facebook_after_body = facebook_after_body
    @facebook_button     = facebook_button(url_with_low_level_and_language)

    Vote.vote_this(@post, nil, current_user_obj)
    if js_format
      render "show.js", :locals => {:post => @post}
    else
      render "show"
    end
  end

  def new
    post = Post.new
    post.prepare_for_editing
    the_problem = nil
    the_problem = Post.find(params[:post_id]) if params[:post_id]
    render "form", :locals => {:post => post, :the_problem => the_problem}
  end

  def new_idea
    new
  end

  def new_idea_step_1
    new
  end

  def new_idea_step_2
    new
  end

  def edit
    #　http://localhost:3000/Ideas/World/posts/196/edit
    @post.prepare_for_editing
    render "form", :locals => {:post => @post, :the_problem => nil}
  end

  def create
    # @post = Post.new(params[:post])
    @post.prepare_for_editing
    @post.user_id = current_user_id
    @post.website_id = current_website_id
    the_problem = nil
    if params[:the_problem]
      the_problem = Post.find(params[:the_problem])
      @post.post_id = params[:the_problem]
    end
    if @post.save
      if current_user_is_guest? and (not @post.temporary_email.blank?)
        make_current_user_temporary(@post.temporary_email)
      end
      if    params[:from_action] == "new_idea_step_1"
        redirect_to(new_idea_step_2_path(:post_id => @post.id), :notice => t('problem_created'))
      elsif params[:from_action] == "new_idea_step_2"
        redirect_to(idea_url(@post), :notice => t('idea_created'))
      elsif params[:from_action] == "new_idea"
        redirect_to(idea_path(@post), :notice => t('idea_created'))
      elsif params[:from_action] == "new"
        redirect_to(post_path(@post), :notice => t('problem_created'))
      else
        # Coming for creating the post (problem or idea). Redirecting to view the post
        raise "Not expected to be here"
      end
    else
      # Saving the post anyway!
      # The next line: "post.tags = []" is tricky, I spent few hours before
      # finding this issue. If the keywords are not remove, they are save two
      # times, one with post.save, the other with post.save!(:validate => false)
      # It was hard to find because the validation for tag would stop to create
      # new tags with the same clean_name. But the test would fail because the
      # failing validation. Removing tags before forcing validation seems working
      # just fine.
      @post.tags = []
      @post.save!(:validate => false)
      # The following line, I am not sure if it can create problem. It is necessary
      # because there are two types of "create form", depending on the action that should
      # be preserved from the previous form. One type is for new Idea (2 steps), the other
      # is for new problem (1 step). Forms are basically the same, but the titles are different.
      params[:action] = params[:from_action]
      render "form", :locals => {:post => @post, :the_problem => the_problem}
    end
  end

  def hide
    post = Post.find(params[:id])
    if current_user_can_edit_this_post?(post)
      post.prepare_for_editing
      post.status = "HIDDEN"
      post.save
      redirect_to :back, :notice => t(:hidden)
    else
      redirect_to :back, :notice => t(:you_cannot_edit_this_post)
    end
  end

  def vote
    vote_type = nil
    params.keys.each do |k|
      vote_type = k if k =~ /^vote/
    end
    
#    raise vote_type
    
    @post = Post.find(params[:id])
    authorize! vote_type, @post
    
#    render :js => "alert('#{vote_type}');"
    @vote = Vote.vote_this(@post, vote_type, current_user_obj)
    # params[:vote] can be: :like, :flag, :other_1, :other_2, :other_3
    # User is actually voting on this post
    # flash[:notice] = "Thanks for your review!"
    if js_format
      render "update.js"
    else
      redirect_to :back, :notice => t(:your_selection_has_been_registred)
    end
  end


  def update
    post = Post.find(params[:id])
    post.prepare_for_editing
    if params[:the_problem]
      the_problem = Post.find(params[:the_problem])
    end
    if post.update_attributes(params[:post])
      if current_user_is_guest? and (not post.temporary_email.blank?)
        make_current_user_temporary(post.temporary_email)
      end
      sleep 0.5 # because problem with dreamhost http://stackoverflow.com/questions/7133762/internal-error-html-with-rails-3-app-on-dreamhost
      if    params[:from_action] == "new_idea_step_1"
        redirect_to(new_idea_step_2_path(:post_id => post.id), :notice => t('problem_created'))
      elsif params[:from_action] == "new_idea_step_2"
        redirect_to(idea_url(post), :notice => t('idea_created'))
      elsif params[:from_action] == "new_idea"
        redirect_to(idea_path(post), :notice => t('idea_created'))
      elsif params[:from_action] == "new"
        redirect_to(post_path(post), :notice => t('problem_created'))
      elsif params[:from_action] == "edit"
        redirect_to(post_path(post), :notice => t('problem_updated'))
      else
        # Coming for creating the post (problem or idea). Redirecting to view the post
        raise "Not expected to be here"
      end
    else
      # Saving the post anyway!
      post.save(:validate => false)
      params[:action] = params[:from_action]
      render "form", :locals => {:post => post, :the_problem => the_problem}
    end
  end

  def find
  end

  private
  
  def undo_link
    # view_context.link_to("undo", revert_version_path(@item.versions.scoped.last), :method => :post)
  end

  def facebook_after_body
    locale = "en_US"
    if I18n.locale == :it
      locale = "it_IT"
    end
    "<div id='fb-root'></div>
      <script>(function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src = '//connect.facebook.net/#{locale}/all.js#xfbml=1';
        fjs.parentNode.insertBefore(js, fjs);
      }(document, 'script', 'facebook-jssdk'));</script>".html_safe
  end
  def facebook_button(url)
    "<div style='padding-top: 0px' class='fb-like' data-href='#{url}' data-send='false' data-layout='button_count' data-width='130' data-show-faces='false' data-action='recommend'></div>".html_safe
  end
end
  # Need to implement this, probably:
  # http://stackoverflow.com/questions/1578633/sti-and-form-for-problem
  #
  #def CasesController
  #  request.fullpath =~ /\/([^\/]*)/
  #  if $1 == "cases"
  #    return "Case".constantize
  # elsif $1 == "ideas"
  #    return "Idea".constantize
  #  elsif $1 == "locations"
  #    return "Location".constantize
  #  elsif $1 == "events"
  #    return "Event".constantize
  #  elsif $1 == "sales"
  #    return "Sale".constantize
  #  elsif $1 == "articles"
  #    return "Article".constantize
  #  elsif $1 == "facts"
  #    return "Fact".constantize
  #  else
  #    return "Item".constantize
  #  end
  #end

