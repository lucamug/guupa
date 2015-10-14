class UserMailer < ActionMailer::Base
  default :from => "do_not_reply@guupa.com"

  # def welcome_email(user)
  #   @user = user
  #   @url  = "http://example.com/login"
  #   mail(:to => 'l.mugnaini@gmail.com', :subject => "Welcome to My Awesome Site")
  # end  

  def password_reset(user, area, website)
    @user    = user
    @area    = area
    @website = website
    mail(:to => user.email, :subject => t(:subject_password_reset))
  end
  
  def email_confirmation(user, area, website)
    @user    = user
    @area    = area
    @website = website
    mail(:to => user.email, :subject => t(:subject_email_confirmation))
  end

  def message_between_users(user, message)
    @message = message
    mail(:to => user.email, :subject => t(:subject_you_received_a_message))
  end

end
