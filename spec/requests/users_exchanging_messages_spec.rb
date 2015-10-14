# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}

describe "Users Exchanging Messages" do

  before(:each) do
    # Changing language to Italian
    visit root_path(default.merge(:l => :it))
  end

  describe "Two users ('user_from' and 'user_to'), one logged in" do

    user_with_email_confirmed = ""
    user_with_email_NOT_confirmed = ""
    user_to = ""

    before(:each) do
      user_with_email_confirmed     = Factory(:user, :messages_token => "token_1", :email_confirmed => true)
      user_with_email_NOT_confirmed = Factory(:user, :messages_token => "token_1")
      user_to   = Factory(:user, :messages_token => "token_2")
    end

    it "user should get an error because it did not confirmed email yet" do
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user_with_email_NOT_confirmed.email
      fill_in "connection[password]", :with => user_with_email_NOT_confirmed.password
      click_button I18n.t(:sign_in)
      page.should have_content(user_with_email_NOT_confirmed.username)
      visit new_message_path(default.merge(:token => user_to.messages_token))
      page.should have_content(I18n.t(:you_are_not_authorized))
    end

    describe "User confirmed email"

      before(:each) do
        visit sign_in_path(default)
        fill_in "connection[email]",    :with => user_with_email_confirmed.email
        fill_in "connection[password]", :with => user_with_email_confirmed.password
        click_button I18n.t(:sign_in)
        page.should have_content(user_with_email_confirmed.username)
      end

      it "user should get an error message if the token is wrong I" do
        visit new_message_path(default.merge(:token => "WrongToken"))
        page.should have_content(I18n.t(:wrong_token))
      end

      it "user should get an error if the body is empty" do
        visit new_message_path(default.merge(:token => user_to.messages_token))
        click_button I18n.t(:send_message)
        page.should have_content(I18n.t(:the_form_has_errors))
      end

      describe "user_with_email_confirmed send a message to user_to" do
        
        before(:each) do
          visit new_message_path(default.merge(:token => user_to.messages_token))
          fill_in "message[body]", :with => "Hi! How are you doing?"
          click_button I18n.t(:send_message)
        end

        it "page shold have a notice 'message_sent'" do
          page.should have_content(I18n.t(:message_sent))
        end

        it "user_from should see the message in its list" do
          page.should have_content("Hi! How are you doing?")
        end

        it "user_from should see the name of user_to in the list" do
          page.should have_content(user_to.username)
        end
        
        it "user_to should receive a message" do
          last_email.to.should include(user_to.email)
        end

        describe "when user_to log_in" do
          
          before(:each) do
            visit sign_in_path(default)
            fill_in "connection[email]",    :with => user_to.email
            fill_in "connection[password]", :with => user_to.password
            click_button I18n.t(:sign_in)
            visit messages_path(default)
          end

          it "user_to should be logged in" do
            page.should have_content(user_to.username)
          end

          it "user_to should see the message in its list" do
            page.should have_content("Hi! How are you doing?")
          end

          it "user_to should see the name of user_to in the list" do
            page.should have_content(user_with_email_confirmed.username)
          end

        end
    end
  end
end
