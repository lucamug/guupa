class ConnectionsController < ApplicationController
  skip_authorization_check :only => [:create, :destroy, :destroy_all, :new]
  # Create and destroy Connection can be done without authorization
  def index
  end

  def new
    current_user_obj
    @user = User.new
    @connection = Connection.new(:remember_me => true)
  end

  def create # User logging in
    @connection = Connection.new(params[:connection])
    if @connection.valid?
      @user = User.authenticate(@connection.email, @connection.password)
      if @user
        login_this_user(@user, params[:connection][:remember_me].to_i)
        redirect_to root_url, :notice => t(:user_signed_in)
      else
        flash.now.alert = t(:invalid_email_or_password)
        @user = User.new
        render "new"
      end
    else
      # Connection did not validate
      @user = User.new
      render "new"
    end
  end

  def destroy
    logout_this_user
    redirect_to root_url, :notice => t(:signed_out)
  end

  def destroy_all
    logout_this_user_from_all
    redirect_to root_url, :notice => t(:signed_out_from_all)
  end
end

