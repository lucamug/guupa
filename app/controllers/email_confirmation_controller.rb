class EmailConfirmationController < ApplicationController
  skip_authorization_check :only => [:edit]
  # Because the edit action need to 
  # be done also without authorization. 
  
  def new
    @user = current_user_obj
    authorize! :update, @user
    @user.send_email_confirmation(current_area_translated, current_website_translated)
    redirect_to root_path, :notice => t(:new_email_confirmation_sent)
  end

  def edit
    # User clicking on the link that received by email. No authorizations is needed
    # Is when a user return to the site
    # clicking on "confirm email" received by email.
    @user = User.find_by_email_confirmation_token!(params[:id])
    @user.email_confirmed = true
    @user.save!
    redirect_to root_url, :notice => t(:email_confirmed)
  end

end
