# encoding: UTF-8
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
describe "UserLogin" do

  before(:each) do
    # Changing language to Italian
    visit root_path(default.merge(:l => :it))
  end

  describe "Registering a new user" do

    user = ""    
    
    before(:each) do
      user = User.new(:username => "Test1", :email => "a@a.com", :password => "secret")
      I18n.locale = :it
      visit sign_in_path(default)
      fill_in "user[username]",              :with => user.username
      fill_in "user[email]",                 :with => user.email
      fill_in "user[password]",              :with => user.password
    end
  
    describe "with valid credentials" do 

      before(:each) do
        click_button I18n.t(:create_a_new_user_and_sign_in)
      end

      it "should show the notice 'user_created_and_signed_in'" do
        page.should have_content I18n.t(:user_created_and_signed_in)
        # save_and_open_page
        # show_me_the_cookies
        # puts last_email.inspect
        last_email.to.should include(user.email)
      end

      it "should have the name at the top right corner" do
        page.should have_content(user.username)
      end

      it "should send email" do
        # puts last_email.inspect
        # last_email.to.should include(user.email)
      end
    end

    describe "without valid credentials" do 

      it "(username is blank) should show the notice 'user_created_and_signed_in'" do
        fill_in "user[username]", :with => ""
        click_button I18n.t(:create_a_new_user_and_sign_in)
        page.should have_content(I18n.t(:the_form_has_errors))
      end
      
      it "(email is blank) should show the notice 'user_created_and_signed_in'" do
        fill_in "user[email]", :with => ""
        click_button I18n.t(:create_a_new_user_and_sign_in)
        page.should have_content(I18n.t(:the_form_has_errors))
      end

    end
  end

  describe "The user already registered" do
    
    user = ""

    before(:each) do
      user = Factory(:user)
      I18n.locale = :it
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user.email
      fill_in "connection[password]", :with => user.password
    end
    
    describe "with valid credentials" do 

      before(:each) do 
        click_button I18n.t(:sign_in)
      end

      it "Page should get 'user_signed_in' notice" do
        page.should have_content(I18n.t(:user_signed_in))
      end

      it "Page should have the username at the top right" do
        page.should have_content(user.username)
      end

    end 

    describe "with invalid credentials" do 

      it "Page should not let user login if the password is wrong" do
        fill_in "connection[password]", :with => user.password + "x"
        click_button I18n.t(:sign_in)
        page.should have_content(I18n.t(:invalid_email_or_password))
        page.should have_content(I18n.t(:sign_in))
      end

      it "Page should not let user login if the email is wrong" do
        fill_in "connection[email]",    :with => user.email + "x"
        click_button I18n.t(:sign_in)
        page.should have_content(I18n.t(:invalid_email_or_password))
        page.should have_content(I18n.t(:sign_in))
      end

      it "The form should be invalid if the email is empty" do
        fill_in "connection[email]", :with => ""
        click_button I18n.t(:sign_in)
        page.should have_content(I18n.t(:the_form_has_errors))
        page.should have_content(I18n.t(:sign_in))
      end
    end

    describe "with tampered cookie" do 

      it "It should not login the user PENDING (Maybe this is not feasable)" do
      end

    end
  end


  describe "The user is signed in" do
    
    user = ""

    before(:each) do
      user = Factory(:user)
      I18n.locale = :it
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user.email
      fill_in "connection[password]", :with => user.password
      click_button I18n.t(:sign_in)
      page.should have_content(I18n.t(:user_signed_in))
    end

    it "Should sign out if click on sign out" do
      visit user_path(user.id, default)
      click_link I18n.t(:sign_out)
      page.should have_content(I18n.t(:sign_in))
    end
  end
end
