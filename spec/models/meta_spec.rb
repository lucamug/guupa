require 'spec_helper'
describe Meta do
  before(:all) do
    
    I18n.locale = :en

    @world = Tag.new()
    @world.id = 1
    @world.name = "World"
    @world.clean_name = "world"
    @world.level = 0
    @world.bounds = "-20000000 000000000 50000000 360000000"
    @world.save!

    @post_1 = Post.new
    @post_1.prepare_for_editing
    @post_1.title       = "Title 1"
    @post_1.description = "Description 1"
    @post_1.tag_names   = "Red, Yellow"
    @post_1.created_at  = 2.days.ago
    @post_1.save!
    
    @post_2 = Post.new
    @post_2.prepare_for_editing
    @post_2.title       = "Title 2"
    @post_2.description = "Description 2"
    @post_2.tag_names   = "Blue, Yellow"
    @post_2.created_at  = 6.hours.ago
    @post_2.save!

    I18n.locale = :it

    @post_3 = Post.new
    @post_3.prepare_for_editing
    @post_3.title       = "Italian Title 3"
    @post_3.description = "Italian Description 3"
    @post_3.tag_names   = "Yellow, Verde"
    @post_3.save!
    
    I18n.locale = :en

    @user_1 = User.new
    @user_1.password = "Secret"
    @user_1.email    = "user_1@example.com"
    @user_1.username = "Pippo1"
    @user_1.save!
    
    @user_2 = User.new
    @user_2.password = "Secret"
    @user_2.email    = "user_2@example.com"
    @user_2.username = "Pippo2"
    @user_2.save!

    Vote.vote_this(@post_3, "vote_1", @user_1)
    Vote.vote_this(@post_3, "vote_1", @user_2)
    Vote.vote_this(@post_2, "vote_1", @user_2)

    Vote.vote_this(@post_2, "vote_2", @user_1)
    Vote.vote_this(@post_2, "vote_2", @user_2)
    Vote.vote_this(@post_1, "vote_2", @user_2)
  end

  it "There should be 6 tags (World + 4 tags + 1 Italian translation)" do
    Tag.should have(6).record
  end

  it "The like counter of post 3 should be 2" do
    @post_3.count_vote_1.should == 2
  end

  it "Should return 2 posts when the Post per page is 2" do
    Post.per_page = 2
    @result = Meta.load_filtered_tags_and_posts
    @result[:paged_post_objs].size.should == 2
  end
  
  it "Should return 3 posts when the Post per page is 10" do
    Post.per_page = 10
    @result = Meta.load_filtered_tags_and_posts
    @result[:paged_post_objs].size.should == 3
  end

  #
  # Possible ordering: 
  # 
  # by like-dislike: votes
  # by views:        views
  # by children:     children (Post with most ideas)
  # by other_1:      other_1
  # by other_2:      other_2
  # by other_3:      other_3
  # by created_at    created
  #

  it "Should return \"Italian Title 3\" if ordered by vote" do
    @result = Meta.load_filtered_tags_and_posts(:order => "vote_1", :direction => :natural)
    @result[:paged_post_objs][0].title.should == "Italian Title 3"
  end
  
  it "Should return \"Title 2\" if ordered by other_1" do
    @result = Meta.load_filtered_tags_and_posts(:order => "vote_2", :direction => :natural)
    @result[:paged_post_objs][0].title.should == "Title 2"
  end

  it "Should return \"Italian Title 3\" if ordered by created" do
    @result = Meta.load_filtered_tags_and_posts(:order => "created", :direction => :natural)
    @result[:paged_post_objs][0].title.should == "Italian Title 3"
  end

#  it "should create a new instance given valid attributes" do
#    Post.create!(@attr)
#  end
#
#  it "should create two tags if prepared for editing, given a tag and changed the locale to :it" do
#    I18n.locale = :it
#    a = Post.new(@attr)
#    a.prepare_for_editing
#    a.tag_names = "tag3"
#    a.save!
#    Tag.first.name.should == "tag3" and Tag.all.size.should == 2
#    I18n.locale = :en
#  end
#
#  context "...is created with one tag" do
#    before(:each) do
#      @attr = {:title => "Shiki", :description => "Nice village in Saitama"}
#      a = Post.new(@attr)
#      a.prepare_for_editing
#      a.tag_names = "tag3"
#      a.save!
#    end
#
#    it "should create a new tag object" do
#      Tag.first.name.should == "tag3" and Tag.all.size.should == 1
#    end
#
#    it "should add one tag given that we add one tag in the tag_name attribute" do
#      b = Post.first
#      b.prepare_for_editing
#      b.tag_names += ", tag4"
#      b.save!
#      Tagging.all.size.should == 2
#    end
#
#    it "should remove all tags if empty tag_name attribute is given" do
#      b = Post.first
#      b.prepare_for_editing
#      b.tag_names = ""
#      b.save!
#      Tagging.all.size.should == 0
#    end
#
#    it "should create two tagging but only one tag if a new post is created with the same tag" do
#      b = Post.new(@attr)
#      b.prepare_for_editing
#      b.tag_names = "tag3"
#      b.save!
#      Tagging.all.size.should == 2 and Tag.all.size.should == 1
#    end
#  end
#  context "...is created with one marker on Scandicci, Italy" do
#    before(:each) do
#      I18n.locale = :en
#      @attr = {:title => "Scandicci", :description => "Nice village in Tuscany"}
#      a = Post.new(@attr)
#      a.prepare_for_editing
#      a.api_data = "lat:43738499; lng:11197274; b:43738390 11197098 43738641 11197803; z:20; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Selve, 50018 Scandicci Florence, Italy"
#      a.save!
#    end
#    it "should create 4 tags: Italy, Toscana, Province of Florence, Scandicci" do
#      tags = Tag.all
#      tags[0].name.should == "Italy"
#      tags[1].name.should == "Toscana"
#      tags[2].name.should == "Province of Florence"
#      tags[3].name.should == "Scandicci"
#    end
  after(:all) do
    Post.delete_all
    Tag.delete_all
    Tagging.delete_all
    Vote.delete_all
    User.delete_all
  end
end

