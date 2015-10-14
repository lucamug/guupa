class MessagesController < ApplicationController

  def new
    @message = Message.new(:messages_token => params[:token])
    authorize! :send, @message, :message => t(:unable_to_send_messages)
    @user = current_user_obj
    if recipient = User.find_by_messages_token(@message.messages_token)
      render "form", :locals => {:message => @message, :recipient => recipient}
    else
      redirect_to :root, :notice => t(:wrong_token)
    end
  end

  def create
    @message = Message.new(params[:message])
    authorize! :send, @message, :message => t(:unable_to_send_messages)
    @user = current_user_obj
    if recipient = User.find_by_messages_token(@message.messages_token)
      @message.user_id        = current_user_id
      @message.recipient_id   = recipient.id
      @message.recipient_type = recipient.class.to_s
      @message.website_id     = current_website_id
      if @message.save
        redirect_to :messages, :notice => t(:message_sent)
        message_body = "\n********************\nFrom: #{@user.username_for_display}\n\n#{@message.body}\n********************\n"
        UserMailer.message_between_users(recipient, message_body).deliver
      else
        render "form", :locals => {:message => @message, :recipient => recipient}
      end
    else
      redirect_to :root, :notice => t(:wrong_token)
    end      
  end

  def index
    authorize! :read, current_user_obj
  end

end
