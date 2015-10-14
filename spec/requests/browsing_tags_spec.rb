# encoding: UTF-8
# save_and_open_page
# show_me_the_cookies
# puts last_email.inspect
# puts current_url
# Help http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Session#html-instance_method
require 'spec_helper'
default = {:website => "Idee", :area => "Scandicci"}
# I18n.locale = :it


describe "Browsing Tags" do

  before(:each) do

    I18n.locale = :it

    world = Tag.new
    world.id = 1
    world.name = "World"
    world.clean_name = "world"
    world.level = 0
    world.bounds = "-20000000 000000000 50000000 360000000"
    world.save!

    u1 = Factory(:user)
    u2 = Factory(:user)

    p1 = Post.new
    p1.prepare_for_editing
    p1.user_id     = u1.id
    p1.website_id  = 2
    p1.title       = "Via delle Corbinaie ha due sensi unici opposti che rendono difficile il transito"
    p1.description = "Nell'ultimo tratto della strada che finisce in via Roma ci sono due tratti a senso unico opposti che non hanno molto senso."
    p1.tag_names   = "Senso Unico, Traffico Difficoltoso"
    p1.map_data    = "lat:43749446; lng:11186518; b:43748740 11183921 43750748 11189565; z:17; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Corbinaie, 15, 50018 Scandicci Florence, Italy; v: 1.0"
    p1.save!

    p2 = Post.new
    p2.prepare_for_editing
    p2.user_id     = u1.id
    p2.website_id  = 2
    p2.title       = "Via delle Corbinaie ha due sensi unici opposti che rendono difficile il transito"
    p2.description = "Nell'ultimo tratto della strada che finisce in via Roma ci sono due tratti a senso unico opposti che non hanno molto senso."
    p2.tag_names   = "Senso Unico, Traffico Difficoltoso, Tag 3"
    p2.map_data    = "lat:43749446; lng:11186518; b:43748740 11183921 43750748 11189565; z:17; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Corbinaie, 15, 50018 Scandicci Florence, Italy; v: 1.0"
    p2.save!

     # visit root_path(default)
     # puts Tag.all.map{|t| t.clean_name}.join(", ")
  end

  it "there should be 11 tags" do
    Tag.all.size.should == 11 # 8 Tags + 3 in Italian
  end

  it "Clicking on 'Senso Unico' should return 2 items" do
    visit root_path(default.merge(:l => :it))
    click_on "Senso Unico"
    page.should have_content( I18n.t("will_paginate.page_entries_info.single_page.other", :count => 2) )
  end

  it "Clicking on 'Tag 3' should return 1 item" do
    visit root_path(default.merge(:l => :it))
    click_on "Tag 3"
    page.should have_content( I18n.t("will_paginate.page_entries_info.single_page.one", :count => 1) )
  end

  it "Clicking on 'Toscana' should..." do
    visit root_path(default.merge(:l => :it))
    click_on "Toscana"
    page.should have_content("Idee per la Toscana")
  end

  it "Well known bug! Urls like /Scandicci/Toscana should not consider 'Toscana' as a tag!"
#   do
#    visit root_path(default.merge(:l => :it, :tag_1 => "Toscana"))
#    page.should have_no_content(I18n.t :tags_selected)
#  end

end
