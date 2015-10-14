# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Idee", :area => "World"}
I18n.locale = :it
describe "Voting System" do
  user_1 = nil
  user_2 = nil
  p1 = nil

  describe "Two users created, one log in" do

    before(:each) do
      user_1 = Factory(:user, :email_confirmation_token => "token_1", :email_confirmed => true)
      user_2 = Factory(:user, :email_confirmation_token => "token_2")
      visit root_path(default)
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user_1.email
      fill_in "connection[password]", :with => user_1.password
      click_button I18n.t(:sign_in)

      p1 = Post.new
      p1.prepare_for_editing
      p1.user_id     = user_1.id
      p1.website_id  = 2
      p1.title       = "Via delle Corbinaie ha due sensi unici opposti che rendono difficile il transito"
      p1.description = "Nell'ultimo tratto della strada che finisce in via Roma ci sono due tratti a senso unico opposti che non hanno molto senso."
      p1.tag_names   = "Senso Unico, Traffico Difficoltoso"
      p1.map_data    = "lat:43749446; lng:11186518; b:43748740 11183921 43750748 11189565; z:17; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Corbinaie, 15, 50018 Scandicci Florence, Italy; v: 1.0"
      p1.save

      visit root_path(user_1, default.merge(:l => I18n.locale))
    end
    
    it "Test" do
      click_on p1.title
      click_on I18n.t("voting.is_important")
      p1.reload
      p1.count_vote_4.should == 1
    end
  end
end
