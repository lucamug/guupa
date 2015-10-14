# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
area = "World"
website = "Ideas"

describe "Visit the home page" do

  before(:each) do
    visit root_path(:area => area, :website => website)
  end
  
  it "Page should be in the defalt language (English)" do
    page.should have_content("Ideas") # English default language
  end

  describe "Clicking on language button 'Italian'" do

    before(:each) do
      click_on "Italian"
    end

    it "Page should be in Italian" do
      page.should have_content("Idee")
    end

    it "Page should be in Italian also reloading the home page" do
      visit root_path(:area => area, :website => website)
      page.should have_content("Idee")
    end

  end


#  describe "User create the invalid Problem" do
#
#    before(:each) do
#      visit root_path(:area => area)
#      click_on I18n.t(:i_have_a_new_idea)
#      fill_in "post[title]",       :with => ""
#      fill_in "post[description]", :with => "Description Problem"
#      click_on I18n.t(:save_the_problem)
#    end
#    
#    it "Page should have error of invalid form" do
#        page.should have_content(I18n.t(:the_form_has_errors))
#    end
#
#    it "The post should be saved anyway (for attachments)" do
#        Post.all.size.should == 1
#    end
#
#    it "If the user submit the form again, same result" do
#        click_on I18n.t(:save_the_problem)
#        page.should have_content(I18n.t(:the_form_has_errors))
#        Post.all.size.should == 1
#    end
#
#    describe "User fix the problem and go to the idea step" do
#
#      before(:each) do
#        fill_in "post[title]",       :with => "Title"
#        click_on I18n.t(:save_the_problem)
## save_and_open_page
#      end
#      
#      it "Page should say 'Problem Created'" do
#        page.should have_content(I18n.t(:problem_created))
#      end
#
#      describe "User save an invalid idea" do
#
#        before(:each) do
#          fill_in "post[description]", :with => "Description Idea"
#          click_on I18n.t(:save_the_idea)
#        end
#
#        it "Page should have error of invalid form" do
#         page.should have_content(I18n.t(:the_form_has_errors))
#        end
#
#        it "The post should be saved anyway (for attachments)" do
#            Post.all.size.should == 2
#        end
#
#        it "If the user submit the form again, same result" do
#            click_on I18n.t(:save_the_idea)
#            page.should have_content(I18n.t(:the_form_has_errors))
#            Post.all.size.should == 2
#        end
#
#      end
#    end
#  end
#
#  describe "User create the Problem first" do
#
#    before(:each) do
#      visit root_path(:area => area)
#      click_on I18n.t(:i_have_a_new_idea)
#      fill_in "post[title]",       :with => "Title Problem"
#      fill_in "post[description]", :with => "Description Problem"
#      fill_in "post[map_data]",    :with => "lat:43754204; lng:11183337; b:43538564 10765856 43795851 11504687; z:10; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via San Bartolo in Tuto, 22-24, 50018 Scandicci Florence, Italy; v: 1.0"
#      click_on I18n.t(:save_the_problem)
#    end
#
#    it "Page should say 'Problem Created'" do
#      page.should have_content(I18n.t(:problem_created))
#    end
#
#    it "Page should show the title fo the problem'" do
#      page.should have_content("Title Problem")
#    end
#
#    describe "Users coninuing on the step 2 (The Idea)" do
#
#      before(:each) do
#        fill_in "post[title]",       :with => "Title Idea"
#        fill_in "post[description]", :with => "Description Idea"
#        click_on I18n.t(:save_the_idea)
#      end
#
#      it "Page should say 'Idea Created'" do
#        page.should have_content(I18n.t(:idea_created))
#      end
#
#      it "Page should show both titles of the Problem and the Idea" do
#        page.should have_content("Title Problem")
#        page.should have_content("Title Idea")
#      end
#    end
#  end
end
