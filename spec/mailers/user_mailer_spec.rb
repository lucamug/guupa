require "spec_helper"
default = {:website => "Ideas", :area => "World"}
I18n.locale = :it
describe UserMailer do
  describe "password_reset" do
    let(:user) { Factory(:user, :password_reset_token => "anything") }
    let(:mail) { UserMailer.password_reset(user, default[:area], default[:website]) }

    it "send user password reset url" do
      mail.subject.should eq(I18n.t(:subject_password_reset))
      mail.to.should eq([user.email])
      mail.from.should eq(["do_not_reply@guupa.com"])
      mail.body.encoded.should match(edit_password_reset_path(user.password_reset_token, default))
    end

  end
  describe "email_confirmation" do
    let(:user) { Factory(:user, :email_confirmation_token => "anything") }
    let(:mail) { UserMailer.email_confirmation(user, default[:area], default[:website]) }

    it "send user email confirmation url" do
      mail.subject.should eq(I18n.t(:subject_email_confirmation))
      mail.to.should eq([user.email])
      mail.from.should eq(["do_not_reply@guupa.com"])
      mail.body.encoded.should match(edit_email_confirmation_path(user.email_confirmation_token, default))
    end

  end
end
