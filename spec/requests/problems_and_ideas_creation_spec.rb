# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Ideas", :area => "World"}
describe "Users following step 1 (The Problem) of the two steps process Problem + Idea" do

  it "User create a problem in Japan" do
    visit root_path(default.merge(:l => :it))
    click_on I18n.t(:i_have_a_new_problem)
    fill_in "post[title]",       :with => "TitleAAA"
    fill_in "post[description]", :with => "Desc"
    fill_in "post[map_data]",    :with => "lat:35658063; lng:139702484; b:35657686 139702041 35658251 139703393; z:19; c:Japan(24045999 122933785 45556865 148895291); 3:Tokyo(35501190 138942758 35898644 139919853); 4:Shibuya(35641564 139661354 35692141 139723895); 5:Shibuya(35653471 139701091 35664155 139713965); p:150-0031(35653122 139694966 35661789 139705178); a:Tamagawa Dori, 150-0002, Japan; v: 1.0"
    fill_in "post[tag_names]",   :with => "AAA"

# puts Tag.all.map{|t| t.clean_name}.inspect

    click_on I18n.t(:save_the_problem)

# puts Tag.all.map{|t| t.clean_name}.inspect

    page.should have_content(I18n.t(:problem_created))
    visit root_path(default)
# save_and_open_page
    page.should have_content("AAA")
  end

  it "After the form is displayed, a guest user should be created" do
    visit root_path(default.merge(:l => :it))
    click_on I18n.t(:i_have_a_new_idea)
    User.all.size.should == 1
  end

  describe "User create the invalid Problem" do

    before(:each) do
      visit root_path(default.merge(:l => :it))
      click_on I18n.t(:i_have_a_new_idea)
      fill_in "post[title]",       :with => ""
      fill_in "post[description]", :with => "Description Problem"
      click_on I18n.t(:save_the_problem)
    end
    
    it "Page should have error of invalid form" do
        page.should have_content(I18n.t(:the_form_has_errors))
    end

    it "The post should be saved anyway (for attachments)" do
        Post.all.size.should == 1
    end

    it "If the user submit the form again, same result" do
        click_on I18n.t(:save_the_problem)
        page.should have_content(I18n.t(:the_form_has_errors))
        Post.all.size.should == 1
    end

    describe "User fix the problem and go to the idea step" do

      before(:each) do
        fill_in "post[title]",       :with => "Title"
        click_on I18n.t(:save_the_problem)
      end
      
      it "Page should say 'Problem Created'" do
        page.should have_content(I18n.t(:problem_created))
      end

      describe "User save an invalid idea" do

        before(:each) do
          fill_in "post[description]", :with => "Description Idea"
          click_on I18n.t(:save_the_idea)
        end

        it "Page should have error of invalid form" do
         page.should have_content(I18n.t(:the_form_has_errors))
        end

        it "The post should be saved anyway (for attachments)" do
            Post.all.size.should == 2
        end

        it "If the user submit the form again, same result" do
            click_on I18n.t(:save_the_idea)
            page.should have_content(I18n.t(:the_form_has_errors))
            Post.all.size.should == 2
        end

      end
    end
  end
  
  describe "User create the Problem first" do

    before(:each) do
      visit root_path(default.merge(:l => :it))
      click_on I18n.t(:i_have_a_new_idea)
      fill_in "post[title]",       :with => "Title Problem"
      fill_in "post[description]", :with => "Description Problem"
      fill_in "post[map_data]",    :with => "lat:43754204; lng:11183337; b:43538564 10765856 43795851 11504687; z:10; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via San Bartolo in Tuto, 22-24, 50018 Scandicci Florence, Italy; v: 1.0"
      click_on I18n.t(:save_the_problem)
    end

    it "Page should say 'Problem Created'" do
      page.should have_content(I18n.t(:problem_created))
    end

    it "Page should show the title fo the problem'" do
      page.should have_content("Title Problem")
    end

    describe "Users coninuing on the step 2 (The Idea)" do

      before(:each) do
        fill_in "post[title]",       :with => "Title Idea"
        fill_in "post[description]", :with => "Description Idea"
        click_on I18n.t(:save_the_idea)
      end

      it "Page should say 'Idea Created'" do
        page.should have_content(I18n.t(:idea_created))
      end

      it "Page should show both titles of the Problem and the Idea" do
        page.should have_content("Title Problem")
        page.should have_content("Title Idea")
      end
    end
  end
end
