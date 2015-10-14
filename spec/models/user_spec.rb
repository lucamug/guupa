require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
describe User do

  before(:each) do
    @attr = { :password => "Secret", :email => "user@example.com", :username => "Pippo" }
  end

  describe "#send_password_reset" do
    let(:user) { Factory(:user) }

    it "generates a unique password_reset_token each time" do
      user.send_password_reset(default[:area], default[:website])
      last_token = user.password_reset_token
      user.send_password_reset(default[:area], default[:website])
      user.password_reset_token.should_not eq(last_token)
    end

    it "saves the time the password reset was sent" do
      user.send_password_reset(default[:area], default[:website])
      user.reload.password_reset_sent_at.should be_present
    end

    it "delivers email to user" do
      user.send_password_reset(default[:area], default[:website])
      last_email.to.should include(user.email)
    end
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a password" do
    no_name_user = User.new(@attr.merge(:password => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr.merge(:username => "Pippo2"))
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate usernames" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_username = User.new(@attr.merge(:email => "user2@example.com"))
    user_with_duplicate_username.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

end

