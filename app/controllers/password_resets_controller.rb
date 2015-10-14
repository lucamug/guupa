class PasswordResetsController < ApplicationController
  skip_authorization_check :only => [:new, :create, :edit, :update]
  # Becuase user is not logged in during this procedure

  def new
    # User clicked on the "Forgot Password" link, it will show the form
    # to insert the email
  end

  def create
    # User filled the email in the "Forgot Password" form and submit the form.
    # An email will be sent to the user with instructions
    user = User.find_by_encrypted_email( User.encrypt(params[:email]) )
    user.send_password_reset(current_area_translated, current_website_translated) if user
    redirect_to root_path, :notice => t(:email_sent_with_password_reset_instructions)
  end
  
  def edit
    # User clicked on the link to reset the password sent by email. A form
    # to type the new password will be displayed
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  def update
    # User submit the form with the new password on it.
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => t(:password_reset_has_expired)
    elsif @user.update_attributes(params[:user])
      redirect_to root_url, :notice => t(:password_has_been_reset)
    else
      render :edit
    end
  end

end
