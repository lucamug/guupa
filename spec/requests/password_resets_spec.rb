# encoding: UTF-8
require 'spec_helper'
default = {:website => "Idee", :area => "World"}
# I18n.locale = :it

describe "PasswordResets" do

  before(:each) do
    # Changing language to Italian
    visit root_path(default.merge(:l => :it))
  end

  it "emails user when requesting password reset" do
    user = Factory(:user)
    visit sign_in_path(default)
    click_link "password"
    fill_in "Email", :with => user.email
    click_button "Reset Password"
    # save_and_open_page
    # show_me_the_cookies
    current_path.should eq(root_path(default))
    page.should have_content( I18n.t(:email_sent_with_password_reset_instructions) )
    last_email.to.should include(user.email)
  end

  it "does not email invalid user when requesting password reset" do
    visit sign_in_path(default)
    click_link "password"
    fill_in "Email", :with => "nobody@example.com"
    click_button "Reset Password"
    current_path.should eq(root_path(default))
    page.should have_content( I18n.t(:email_sent_with_password_reset_instructions) )
    last_email.should be_nil
  end

  it "updates the user password when confirmation matches" do
    user = Factory(:user, :password_reset_token => "something", :password_reset_sent_at => 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token, default)
    fill_in "Password", :with => "foobar"
    click_button I18n.t(:update_password)
    page.should have_content(I18n.t(:password_has_been_reset))
  end

  it "reports when password token has expired" do
    user = Factory(:user, :password_reset_token => "something", :password_reset_sent_at => 5.hour.ago)
    visit edit_password_reset_path(user.password_reset_token, default)
    fill_in "Password", :with => "foobar"
    click_button I18n.t(:update_password)
    page.should have_content(I18n.t(:password_reset_has_expired))
  end

  it "raises record not found when password token is invalid" do
    lambda {
      visit edit_password_reset_path("invalid", default)
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end

end
