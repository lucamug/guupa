class UsersController < ApplicationController
  load_and_authorize_resource

  def create
    # Create a registered user
    if @user.save
      login_this_user(@user)
      @user.send_email_confirmation(current_area_translated, current_website_translated)
      redirect_to user_url(@user), :notice => t(:user_created_and_signed_in)
    else
      @connection = Connection.new
      render "connections/new"
    end
  end

  def edit_email
  end
    

  def to_temporary
  end

  def to_temporary_update
    # Create a temporary user
    @user.subtype = "temporary"
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice => t(:you_are_temporary_now)
    else
      render "to_temporary"
    end
  end

  def update_email
    if @user.authenticate?(params[:user][:password])
      @user.email_confirmed = false
      if @user.update_attributes(params[:user])
        @user.send_email_confirmation(current_area_translated, current_website_translated)
        redirect_to @user, :notice => t(:email_updated)
      else
        render "edit_email"
      end
    else
      flash.now[:notice] = t(:password_not_valid)
      render "edit_email"
    end
  end

  def edit_password
  end
    
  def update_password
    if @user.authenticate?(params[:user][:old_password])
      if @user.update_attributes(params[:user])
        redirect_to @user, :notice => t(:password_updated)
      else  
        render "edit_password"
      end
    else
      flash.now[:notice] = t(:old_password_not_valid)
      render "edit_password"
    end
  end

  def show
    # Users can filter posts and comments based on
    #
    # - Area
    # - Type (Like, Dislike, Other_1, Other_2, Other_2)
    # - Votable_Type (Post, Comment)
    # - Website
    #
    # By default only show the posts filtered by area and it give the list
    # of posts that belong to other areas (at what level?), and also other websites.
    #
    #  if js_format
    #    data = Meta.load_user_posts(
    #      :website_id => current_website_id,
    #      :user_id    => current_user_id
    #    )
    #    #render "index"
    #    render :json => data
    #  else
    if @user.visible?
      render :show
    else
      render :user_deleted
    end
  end

  def password_reset
  end

  def destroy
    if current_user_obj.id = @user.id
      @user.status = "REMOVED_BY_USER"
    elsif
      @user.status = "REMOVED_BY_OTHER"
    end
    @user.save!
    redirect_to :root, :notice => t(:profile_deleted)
  end

  def password_reset_send
    if user = User.find_by_email(params[:email])
      user.send_password_reset(current_area_translated, current_website_translated)
      redirect_to :root, :notice => "Email sent with password reset instructions."
    else
      redirect_to :back, :notice => "Email not found."
    end
  end

end

