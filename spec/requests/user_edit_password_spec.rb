# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
describe "Users Edit Password" do

  user_1 = nil
  user_2 = nil
  new_password = "pippo54"

  describe "Two users created, one log in" do

    before(:each) do
      user_1 = Factory(:user, :messages_token => "token_1")
      user_2   = Factory(:user, :messages_token => "token_2")
      visit root_path(default)
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user_1.email
      fill_in "connection[password]", :with => user_1.password
      click_button I18n.t(:sign_in)
      visit user_path(user_1, default.merge(:l => :it))
    end
    
    describe "The logged user change the password" do
      before(:each) do
        click_on I18n.t(:edit_password)
        fill_in "user[old_password]", :with => user_1.password
        fill_in "user[password]", :with => new_password
        click_button I18n.t(:edit_password)
      end
  
      it "Page should have 'password_updated'" do
        page.should have_content(I18n.t(:password_updated))
      end

      it "Logging out and in with old password should fail" do
        visit sign_out_path(default)
        page.should have_content(I18n.t(:signed_out))
        visit sign_in_path(default)
        fill_in "connection[email]",    :with => user_1.email
        fill_in "connection[password]", :with => user_1.password
        click_button I18n.t(:sign_in)
        page.should have_content(I18n.t(:invalid_email_or_password))
      end
 
      it "Logging out and in with new password should succed" do
        visit sign_out_path(default)
        page.should have_content(I18n.t(:signed_out))
        visit sign_in_path(default)
        fill_in "connection[email]",    :with => user_1.email
        fill_in "connection[password]", :with => new_password
        click_button I18n.t(:sign_in)
        page.should have_content(I18n.t(:signed_in))
#  save_and_open_page      
#  puts current_url
      end
    end
  end
end
