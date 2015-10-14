# encoding: UTF-8
class ApplicationController < ActionController::Base
  check_authorization # :unless => :rails_admin_controller?
  #check_authorization
  # from http://stackoverflow.com/questions/5441798/global-variable-in-rails
  helper_method :show_debug?  

  def show_debug?
    return true if (Rails.env.development? or Rails.env.test?) and false
    return false
  end

  rescue_from CanCan::AccessDenied do |exception|
    message = ""
    if show_debug?
      br = "<br />"
      if js_format
        br = "\\n"
      end
      message = t(:you_are_not_authorized)
      message += br
      message += br
      message += "Action: #{exception.action}#{br}"
      message += "Subject: #{exception.subject.class}#{br}"
      message += "Subject.id: #{exception.subject.id}#{br}"
#      message += "Params: #{params.inspect}#{br}"
#      message = message.html_safe
#      message.gsub(/"/, "")
#      message = "Ciao"
    elsif exception.action == "vote_2"
      message = t(:you_cannot_volunteer_unless_you_register)
    elsif exception.action =~ /^vote/
      message = "You cannot vote!"
    else
      message = t(:you_are_not_authorized)
    end
    if js_format
      render :js => "alert(\"#{message}\")"
    else
      redirect_to root_url, :alert => message
    end
  end


  helper_method :supported_cookies?
  helper_method :js_format
  helper_method :current_page
  helper_method :current_user
  helper_method :current_user_obj
  helper_method :current_user_id
  helper_method :current_connection_obj
  helper_method :current_website_id
  helper_method :current_area_obj
  helper_method :current_area_id
  helper_method :current_area_translated
  helper_method :current_area_children_objs
  helper_method :current_area_children_ids
  helper_method :current_area_ancestors_objs
  helper_method :current_area_ancestors_ids
  helper_method :world_obj
  helper_method :world_translated
  helper_method :stopw

  helper_method :current_user_is_guest?
  helper_method :current_user_is_temporary?
  helper_method :current_user_is_registered?


  helper_method :uri_current_escaped

  helper_method :current_nongeo_filter_objs
  helper_method :current_nongeo_filter_ids

  helper_method :layout_with_map?
  helper_method :my_var
#  helper_method :signed_in? 
#  helper_method :connected_in? 

  helper_method :uri_escape

#  helper_method :current_user_can_edit_this_comment?
#  helper_method :current_user_can_edit_this_post?
#  helper_method :current_user_can_send_emails?

  helper_method :current_website_obj
  helper_method :current_website_translated

  helper_method :logo_ascii

  def current_website_translated
    current_website_obj.translated
  end

  def current_website_obj
    if @current_website_obj
      return @current_website_obj
    else
      @current_website_obj = Website.new
      @current_website_obj.id = 2
      return @current_website_obj
    end
  end

  protect_from_forgery
  # session :disabled => true

#  def user_for_paper_trail
#    # https://github.com/ryanb/railscasts/blob/master/app/controllers/application_controller.rb 
#    current_user_obj && current_user_obj.id
#  end

  def aaaa_current_user
    # Util.my_log "ApplicationController#current_user: called by #{caller[0]}"
    return current_user_id
  end

  def current_user_id
    # Util.my_log "ApplicationController#current_user_id: called by #{caller[0]}"
    current_user_obj && current_user_obj.id
  end


#  def current_user_can_edit_this_comment?(comment)
#    if comment.user_id == current_user_id
#      return true
#    else
#      return false
#    end
#  end
#
#  def current_user_can_edit_this_post?(post)
#    if post.user_id == current_user_id
#      return true
#    else
#      return false
#    end
#  end
#
#
#  def current_user_can_send_emails?
#    not current_user_obj.nil?
#  end






  #############################################################################
  # Remove current_user from the following list because it make each page to  #
  # query the database. I put it here for the moment because otherwise the    #
  # language does not work!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
  #############################################################################
  before_filter :log_start, :supported_cookies?, :error_if_post_request_and_no_cookies, :current_user_obj, :create_guest_user_if_necessary, :set_the_language, :format_from_url

  def log_start
    Util.my_log "\n" * 4 + "_" * 100 + "\n" + "-" * 100 + "\n"
    stopw.take_time("ApplicationController#log_start: START")
  end

  def supported_cookies?
    # ATTENTION!
    # This method need to be run at list once, otherwise the tests with copybara will fails.
    if @supported_cookies_test_already_done
      return @supported_cookies
    else
      if session[:cookies_test] == "ok" or cookies[:auth_token]
        @supported_cookies = true
      else
        session[:cookies_test] = "ok"
        @supported_cookies = false
      end
      # Util.my_log("ApplicationController#supported_cookies? - called by #{caller[0]}. Result: [#{@supported_cookies.inspect}]")
      @supported_cookies_test_already_done = true
      Util.my_log "ApplicationController#supported_cookies? #{@supported_cookies}"
      return @supported_cookies
    end
  end

  def error_if_post_request_and_no_cookies
    # post request always return error in case cookies are not activated
    if (request.post? || request.put? || (params[:action] =~ /new/)) and (not supported_cookies?)
      Util.my_log "ApplicationController#error_if_post_request_and_no_cookies: error!"
      if js_format
        render :js => "alert(\"#{t :cookies_error_for_javascript_alert}\")"
      else
        redirect_to cookies_error_path
      end
    else
      Util.my_log "ApplicationController#error_if_post_request_and_no_cookies: NO error"
    end
  end      

  def create_guest_user_if_necessary
    Util.my_log "ApplicationController#create_guest_user_if_necessary: START #{params.inspect}"
    if supported_cookies? && current_user_obj.nobody?
      Util.my_log "ApplicationController#create_guest_user_if_necessary: Nobody currently logged in and cookies ok"
      # Create guest user only if nobody is currently logged in and the browser
      # support cookies
#      if (request.post? || request.put?)
#        Util.my_log "ApplicationController#create_guest_user_if_necessary: NEED GUEST: post or put request"
#        # User submitted some form or some request to modify the database
#        create_and_login_guest_user
      if params[:controller] =~ /pages/
        Util.my_log "ApplicationController#create_guest_user_if_necessary: NO NEED GUEST: pages request"
        # Don't need user - Help and Privacy
      elsif params[:controller] =~ /connections/ && params[:action] =~ /new|create/
        Util.my_log "ApplicationController#create_guest_user_if_necessary: NO NEED GUEST: sign in form"
        # User on the login form. No need to create a guest user just before 
        # the user is loggin in
      elsif params[:action] =~ /index|index_with_tags/
        Util.my_log "ApplicationController#create_guest_user_if_necessary: NO NEED GUEST: main page"
        # Don't need user - Main pages 
      else
        Util.my_log "ApplicationController#create_guest_user_if_necessary: NEED GUEST: everything else"
        create_and_login_guest_user
      end
    end
  end

  def aaaaaaaaaaaaaa_connected_in?
    if current_user_obj and current_connection_obj
      return true
    else
      return false
    end
  end

  def current_user
    current_user_obj
  end

  def current_user_is_guest?
    current_user_obj and current_user_obj.guest?
  end

  def current_user_is_temporary?
    current_user_obj and current_user_obj.temporary?
  end
  
  def current_user_is_registered?
    current_user_obj and current_user_obj.registered?
  end


  def aaaaaaaaaaaaaaaaaaa_signed_in?
    if current_user_obj and current_user_obj.email !~ /\.guest$/
      return true
    else
      return false
    end
  end









  def uri_escape(text)
    return URI.escape(text.gsub(" ", "_"))
  end

    # Replace the following lines with "current_page"
  def current_page
    unless @page
      @page = params[:page].to_i
      @page = 1 unless @page
      @page = 1 if @page < 1
    end
    return @page
  end

  def format_from_url
    # This part in necessary because the routing system is not able to extract
    # the format for the url, otherwise it would not be possible to have dots
    # in the url. See
    # http://coding-journal.com/rails-3-routing-parameters-with-dots/
    # for more info
    return @format_from_url if @format_from_url
    @format_from_url = :not_found
    names = %w( area tag_1 tag_2 tag_3 tag_4 )
    names.each do |name|
      if the_match = /\.js$/i.match(params[name])
        params[name] = the_match.pre_match
        @format_from_url = :js
      end
    end
    return @format_from_url
  end

  def js_format
    return format_from_url == :js || request.env["HTTP_ACCEPT"] =~ /javascript/i || params[:format] == "js"
  end

  def current_website_id
    return current_website_obj.id
  end

  def aaaaaaaaaaaaaaaaa_current_website_id
    return 2
    unless @current_website_id
      @current_website_id = 0
      Util.my_log("ApplicationController#current_website_id - First time called for #{request.subdomain}")
      request.subdomain.gsub(/^www\./, "")
      if request.subdomain =~ /^(world-heritage)$/
        @current_website_id = 1
        @current_website_name = "World Heritage"
      elsif request.subdomain =~ /^(ideas|idee)$/
        @current_website_id = 2
        @current_website_name = "Ideas"
      else
        @current_website_id = 0
      end
      Util.my_log("ApplicationController#current_website_id - Return #{@current_website_id}")
    end
    return @current_website_id
  end
 
  def current_area_obj;            @current_area_obj            ||= Tag.my_find_by_dirty_name(params[:area]) || world_obj end
  def current_area_children_objs;  @current_area_children_objs  ||= current_area_obj.my_find_children  end
  def current_area_ancestors_objs; @current_area_ancestors_objs ||= current_area_obj.my_find_ancestors end
  def current_nongeo_filter_objs;  @current_nongeo_filter_objs  ||= Tag.my_find_by_dirty_name([params[:tag_1], params[:tag_2], params[:tag_3], params[:tag_4]]) end
  def current_geo_filter_objs;     @current_geo_filter_objs     ||= (current_area_ancestors_objs + [current_area_obj]) - [world_obj] end
  def world_translated;            @world_translated            ||= world_obj.translated end

  def world_obj
    return @world_obj if @world_obj
    if world = Tag.my_find_by_id(1)
      @world_obj = world
      return @world_obj
    else
      world = Tag.new
      world.id = 1
      world.name = "World"
      world.clean_name = "world"
      world.level = 0
      world.bounds = "-20000000 000000000 50000000 360000000"
      if world.save
        @world_obj = world
        return @world_obj
      else
        raise("Error while craating the World tag in world_obj in application controller")
      end
    end        
  end

  def current_area_id;            return current_area_obj.id                       end
  def current_area_translated;    return current_area_obj.translated               end
  def current_area_children_ids;  return current_area_children_objs.map {|a| a.id} end
  def current_area_ancestors_ids; return current_area_ancestors_objs.map{|a| a.id} end
  def current_nongeo_filter_ids;  return current_nongeo_filter_objs.map {|a| a.id} end
  def current_geo_filter_ids;     return current_geo_filter_objs.map    {|a| a.id} end

  def uri_current_escaped
    # This nead to provide a cleaned version, removing not exsisting tags,
    # properly translating the exsisitng,
    @current_uri_escaped ||= request.request_uri
  end

  def layout_with_map?
    if (params[:controller] =~ /posts/ and params[:action] =~ /index/) # or (params[:controller] =~ /users/ and params[:action] =~ /show/)
      return true
    else
      return false
    end
  end

  def can_user_create_comments_on_this_commentable?(commentable_id, commentable_type)
    # Not done yet
    current_user_is_registered? || current_user_is_temporary? || current_user_is_guest?
  end

  def stopw
    @stopw ||= StopWatch.new
  end

  private

  # As per http://stackoverflow.com/questions/6103534/problems-with-link-to
  def default_url_options(options={})
    # This has been added because otherwise link_to helper was generating error
    # because could not find the area. Area also need to be replaced spaces with
    # undelines. Was this a bug?
    to_return = {
      :area => current_area_obj.translated.gsub(" ", "_"),
      :website => current_website_obj.translated.gsub(" ", "_"),
      # :substatus => "all"
    }
    unless supported_cookies?
      # This because in case the user has no cookies, still can browse the site
      # in certain language. Valid for the search engine for example.
      to_return = to_return.merge(:l => I18n.locale)
    end
    return to_return
  end

  def create_and_login_guest_user
    # (:email => Time.now.utc.strftime("%Y%m%d.%H%M%S@") + rand(36**4).to_s(36) + ".guest")
    # user.save(:validate => false)
    user = User.new
    user.subtype = "guest"
    user.save!
    login_this_user(user)
    Util.my_log "ApplicationController#create_and_login_guest_user: Created new user #{user.id} #{user.email} #{caller[0]}"
    return user
  end

  def disactive_connection_with_present_urid
    # Move this to the use model
    connections = Connection.where("user_random_id = ?", session[:urid])
    connections.each do |connection|
      connection.active = false
      connection.save
    end
  end

  def disactive_connection_with_present_user_id
    # Move this to the use model
    # This will remove all connections for the user: "sign_out_all"
    connections = Connection.where("user_id = ?", current_user_id)
    connections.each do |connection|
      connection.active = false
      connection.save
    end
  end

  def clean_user_session
    session[:urid]                 = nil
    session[:user_id]              = nil
    session[:user_email]           = nil
    session[:user_temporary_email] = nil
    session[:user_username]        = nil
  end

  def logout_this_user
    cookies.delete(:auth_token)
  
    #disactive_connection_with_present_urid
    #clean_user_session
    # create_and_login_guest_user
  end
  def logout_this_user_from_all
    disactive_connection_with_present_user_id
    clean_user_session
    # create_and_login_guest_user
  end

  def current_connection_obj
    if @current_connection_obj
      return @current_connection_obj
    else
      return nil
    end
  end

  def make_current_user_temporary(temporary_email)
    if current_user_is_guest?
      current_user_obj.temporary_email = temporary_email
      current_user_obj.save!(:validate => false)
      session[:user_temporary_email] = temporary_email
    end
  end
    

  def login_this_user(user, remember_me = 0)
    connection = user.connections.new
    connection.auth_token     = user.auth_token
    connection.session_id     = session[:session_id].to_s
    connection.ip             = request.remote_ip
    connection.agent          = request.env['HTTP_USER_AGENT']
    connection.remember_me    = true
    connection.save!(:validate => false)
    session[:l]                    = user.locale if user.locale # Bringing back the user preference for language

    if remember_me == 1
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token  
    end
    @current_user_obj = user
  end
  
  def current_user_obj
    @current_user_obj ||= User.find_by_auth_token( cookies[:auth_token] ) if cookies[:auth_token]
    @current_user_obj = User.new if @current_user_obj && (not @current_user_obj.visible?) # Users cannot login if they are not "visible"
    @current_user_obj ||= User.new
  end

  def set_the_language
    #
    # Priorities:
    #
    # 1. param "l" in the URL
    # 2. current_user_obj.locale
    # 3. session[:l]
    # 4. browser
    # 5. default
    #
    if l = sanitize_locale(params[:l])
      # User changed the language
      # Util.my_log "\tLOCALE - User change the language: session #{session.inspect}"
      I18n.locale = l
      session[:l] = l
      if supported_cookies?
        #flash.now[:notice] = t(:language_change_to) + " " + t(I18n.locale)
      end
      Util.my_log "\tLOCALE - Taking locale from URL [#{I18n.locale}], session #{session.inspect}"
      unless current_user_obj.nobody?
        if current_user_obj.locale != l
          current_user_obj.locale = l
          current_user_obj.save!(:validate => false)
        end
      end
    else
      if current_user_obj && (l = sanitize_locale(current_user_obj.locale))
        I18n.locale = l
        session[:l] = l
        Util.my_log "\tLOCALE - Taking locale from database [#{I18n.locale}]"
      elsif l = sanitize_locale(session[:l])
        I18n.locale = l
        session[:l] = l
        Util.my_log "\tLOCALE - Taking locale from session[:l] [#{I18n.locale}]"
      elsif request.env['HTTP_ACCEPT_LANGUAGE'] and l = sanitize_locale(request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first)
        # This part should be done using some plug in that consider also other
        I18n.locale = l
        session[:l] = l
        Util.my_log "\tLOCALE - Taking locale from browser HTTP_ACCEPT_LANGUAGE [#{I18n.locale}]"
      else
        I18n.locale = :en
        session[:l] = l
        Util.my_log "\tLOCALE - Taking locale from default [#{I18n.locale}]"
      end
    end
  end

  def sanitize_locale(locale)
    # available_languages = [:it, :en, :ja]
    available_languages = [:it, :en]
    return nil if locale.blank?
    if ([locale.to_s.to_sym]&available_languages).size == 1
      return locale
    else
      return nil
    end
  end

  def logo_ascii
    return "<!--      
   _____                         
  / ____|                        
 | |  __ _   _ _   _ _ __   __ _ 
 | | |_ | | | | | | | '_ \\ / _` |
 | |__| | |_| | |_| | |_) | (_| |
  \\_____|\\__,_|\\__,_| .__/ \\__,_|
                    | |          
   Share Ideas and  |_|          
   Get Things Done

-->".html_safe
  end
end

# http://patorjk.com/software/taag/
#   _____                         
#  / ____|                        
# | |  __ _   _ _   _ _ __   __ _ 
# | | |_ | | | | | | | '_ \ / _` |
# | |__| | |_| | |_| | |_) | (_| |
#  \_____|\__,_|\__,_| .__/ \__,_|
#                    | |          
#                    |_|          
#Font Name: Big
#
#    __            
#   /__       _  _ 
#   \_||_||_||_)(_|_
#            |
#   Share Ideas and
#   Get Things Done
#
#
#   ____                         
#  / ___|_   _ _   _ _ __   __ _ 
# | |  _| | | | | | | '_ \ / _` |
# | |_| | |_| | |_| | |_) | (_| |
#  \____|\__,_|\__,_| .__/ \__,_|
#                   |_|          
#Font Name: Standard
#
# _____                         
#|  __ \                        
#| |  \/_   _ _   _ _ __   __ _ 
#| | __| | | | | | | '_ \ / _` |
#| |_\ \ |_| | |_| | |_) | (_| |
# \____/\__,_|\__,_| .__/ \__,_|
#                  | |          
#                  |_|          
#
#Font Name: Doom
#
#  ___  _  _  _  _  ____   __  
# / __)/ )( \/ )( \(  _ \ / _\ 
#( (_ \) \/ () \/ ( ) __//    \
# \___/\____/\____/(__)  \_/\_/
#Font Name: Graceful
#
#  __         
# / _       _ 
#(__)(/(//)(/ 
#       /     
#Font Name: Italic
#
# _______                         
#(_______)                        
# _   ___ _   _ _   _ ____  _____ 
#| | (_  | | | | | | |  _ \(____ |
#| |___) | |_| | |_| | |_| / ___ |
# \_____/|____/|____/|  __/\_____|
#                    |_|          
#Font Name: Rounded
#

