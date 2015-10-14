# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
I18n.locale = :it
describe "Users Commenting" do
  user_1 = nil
  user_2 = nil
  p1 = nil

  describe "Two users and one post created" do

    before(:each) do
      user_1 = Factory(:user, :email_confirmation_token => "token_1", :email_confirmed => true)
      user_2 = Factory(:user, :email_confirmation_token => "token_2")
      visit root_path(default)
      visit sign_in_path(default)
      fill_in "connection[email]",    :with => user_2.email
      fill_in "connection[password]", :with => user_2.password
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

      visit post_path(p1, default.merge(:l => I18n.locale))
    end
    
    describe "User 2 create a comment" do

      before(:each) do    
        fill_in "comment[body]", :with => "Comment 1"
        click_button I18n.t("helpers.submit.create", :model => I18n.t("activerecord.models.comment") )
      end

      it "Tha page should conferm the comment creation" do
        page.should have_content(I18n.t("comment.created"))
        page.should have_content("Comment 1")
      end

      it "User update the comment" do
        click_on "Edit_icon_small"
        page.should have_content(p1.title)
        fill_in "comment[body]", :with => "Comment 2"
        click_button I18n.t("helpers.submit.update", :model => I18n.t("activerecord.models.comment") )
        page.should have_content(I18n.t("comment.updated"))
        page.should have_content("Comment 2")
      end

      describe "User 2 logout" do

        before(:each) do
          click_on I18n.t(:sign_out)
        end
        
        it "Should say 'sign out!'" do
          page.should have_content(I18n.t(:signed_out))
        end

        describe "Guest User add comment" do

          before(:each) do
            visit post_path(p1, default.merge(:l => I18n.locale))
            page.should have_content(I18n.t(:guest))
            fill_in "comment[body]", :with => "Comment 3"
            click_button I18n.t("helpers.submit.create", :model => I18n.t("activerecord.models.comment") )
          end

          it "Should have two comments and a destroy button" do
            page.should have_content(I18n.t("comment.created"))
            page.should have_content("Comment 1")
            page.should have_content("Comment 3")
            click_on "Destroy_icon_small"
          end

          # it "Should destroy the comment - Difficult to implement..." do
          #   Capybara.current_session.driver.delete comment_path(User.last.comments[0].id, default)
          #   puts Comment.last.status.inspect
          # end
        end
      end        
    end
  end
end
