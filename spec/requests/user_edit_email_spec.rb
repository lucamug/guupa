# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Idee", :area => "World"}
I18n.locale = :it
describe "Users Edit Email" do

  user_1 = nil
  user_2 = nil
  new_email = "pippo54@a.com"

  describe "Two users created, one log in" do

    before(:each) do
      user_1 = Factory(:user, :email_confirmation_token => "token_1", :email_confirmed => true)
      user_2 = Factory(:user, :email_confirmation_token => "token_2")
      visit root_path(default) # To activate the cookie test
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user_1.email
      fill_in "connection[password]", :with => user_1.password
      click_button I18n.t(:sign_in)
      visit user_path(user_1, default.merge(:l => I18n.locale))
    end
    
    it "The user should have the email confirmed" do
      page.should have_content(I18n.t(:email_confirmed))
    end

    describe "The logged user change the email" do
      before(:each) do
        click_on I18n.t(:edit_email)
        fill_in "user[password]", :with => user_1.password
        fill_in "user[email]",    :with => new_email
        click_button I18n.t(:edit_email)
      end
  
      it "Page should have 'email_updated'" do
        page.should have_content(I18n.t(:email_updated))
      end

      it "should have the new email displayed within the page" do
        page.should have_content(new_email)
      end

      it "The user should have the email NOT confirmed" do
        page.should have_content(I18n.t(:email_not_confirmed).gsub(/<.*?>/, ""))
      end

      it "A mail should be sent to user_1 and should have the correct link" do
        user_1.reload
        last_email.to.should include(new_email)
        last_email.body.should have_content(edit_email_confirmation_url(user_1.email_confirmation_token, default))
      end

      it "User click on the link sent by email, should confirm email" do
        user_1.reload
        visit edit_email_confirmation_path(user_1.email_confirmation_token, default)
        page.should have_content(I18n.t(:email_confirmed))
      end
    end
  end
end
