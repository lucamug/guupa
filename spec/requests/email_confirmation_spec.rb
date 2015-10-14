# encoding: UTF-8
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
describe "Email Confirmation" do

  before(:each) do
    I18n.locale = :it
  end
  
  describe "when the user is logged in" do

    it "flag the user as confirmed email when she click on the link in the email" do
      user = Factory(:user, :email_confirmation_token => "something")
      user.email_confirmed.should == nil
      visit edit_email_confirmation_path(user.email_confirmation_token, default.merge(:l => I18n.locale))
      user.reload
      user.email_confirmed.should == true
      page.should have_content(I18n.t(:email_confirmed))
    end

    it "raises record not found when password token is invalid" do
      lambda {
        visit edit_email_confirmation_path("invalid", default)
      }.should raise_exception(ActiveRecord::RecordNotFound)
    end

  end
end
