require 'spec_helper'
describe Post do
  before(:each) do
    @attr = {:title => "Shiki", :description => "Nice village in Saitama"}
  end

  it "The default I18n.locale should be :en" do
    I18n.locale.should == :en
  end

  it "should create a new instance given valid attributes" do
    Post.create!(@attr)
  end

  it "should create two tags if prepared for editing, given a tag and changed the locale to :it" do
    I18n.locale = :it
    a = Post.new(@attr)
    a.prepare_for_editing
    a.tag_names = "tag3"
    a.save!
    Tag.first.name.should == "tag3" and Tag.all.size.should == 2
    I18n.locale = :en
  end

  context "...is created with one tag" do
    before(:each) do
      @attr = {:title => "Shiki", :description => "Nice village in Saitama"}
      a = Post.new(@attr)
      a.prepare_for_editing
      a.tag_names = "tag3"
      a.save!
    end

    it "should create a new tag object" do
      Tag.first.name.should == "tag3" and Tag.all.size.should == 1
    end

    it "should add one tag given that we add one tag in the tag_name attribute" do
      b = Post.first
      b.prepare_for_editing
      b.tag_names += ", tag4"
      b.save!
      Tagging.all.size.should == 2
    end

    it "should remove all tags if empty tag_name attribute is given" do
      b = Post.first
      b.prepare_for_editing
      b.tag_names = ""
      b.save!
      Tagging.all.size.should == 0
    end

    it "should create two tagging but only one tag if a new post is created with the same tag" do
      b = Post.new(@attr)
      b.prepare_for_editing
      b.tag_names = "tag3"
      b.save!
      Tagging.all.size.should == 2 and Tag.all.size.should == 1
    end
  end
  context "is created with one marker on Scandicci" do
    before(:each) do
      I18n.locale = :en
      @attr = {:title => "Scandicci", :description => "Nice village in Tuscany"}
      a = Post.new(@attr)
      a.prepare_for_editing
      a.map_data = "lat:43738499; lng:11197274; b:43738390 11197098 43738641 11197803; z:20; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Selve, 50018 Scandicci Florence, Italy"
      a.save!
      @id = a.id
    end
    it "should create 4 tags: Italy, Toscana, Province of Florence, Scandicci" do
      tags = Tag.all
      tags[0].name.should == "Italy"
      tags[1].name.should == "Toscana"
      tags[2].name.should == "Province of Florence"
      tags[3].name.should == "Scandicci"
    end
    it "should have no keywords in 'tag_names' after being prepared for editing" do
      b = Post.find(@id)
      b.prepare_for_editing
      b.tag_names.should == ""
    end
    it "should create no new keywords if saved again with empty 'tag_names' field" do
      b = Post.find(@id)
      b.prepare_for_editing
      b.save
      tags = Tag.all
      tags.size.should == 4
    end
    it "should create one new keyword if saved again with 'tag_names' = 'new keyword'" do
      b = Post.find(@id)
      b.prepare_for_editing
      b.tag_names = 'new keyword'
      b.save
      tags = Tag.all
      tags.size.should == 5
    end
    it "should create one new keyword if saved again with 'tag_names' = 'new keyword, scandicci'" do
      b = Post.find(@id)
      b.prepare_for_editing
      b.tag_names = 'new keyword, SCANDICCI,scandicci, italy'
      b.save
      tags = Tag.all
      tags.size.should == 5
    end
  end
end
