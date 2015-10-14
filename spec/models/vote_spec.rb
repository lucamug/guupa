require 'spec_helper'
describe Vote do
  it "Should create 6 tags" do

    @world = Tag.new()
    @world.id = 1
    @world.name = "World"
    @world.clean_name = "world"
    @world.level = 0
    @world.bounds = "-20000000 000000000 50000000 360000000"
    @world.save!

    p4 = Post.new()
    p4.prepare_for_editing
    p4.website_id  = 2 # Ideas
    p4.title       = "Something in Scandicci"
    p4.description = "Description p4"
    p4.tag_names   = "Senso Unico"
    p4.map_data    = "lat:43738502; lng:11197270; b:43738351 11197014 43738602 11197719; z:20; c:Italy(36644174 6626720 47092000 18520362); 3:Toscana(42237643 9686792 44472548 12372326); 4:Florence(43451472 10711114 44239655 11753096); 5:Scandicci(43685422 11083934 43786235 11225061); p:50018(43685422 11083934 43786235 11225061); a:Via delle Selve, 50018 Scandicci Florence, Italy"
    p4.id          = 3
    p4.save!

    u1 = User.new
    u1.username = 'FirstUser'
    u1.email = 'a@a.com'
    u1.password = 'Secret'
    u1.save!

    toscana = Tag.find_by_clean_name("toscana")
    toscana.language = "it"
    toscana.save

    Tag.find_by_clean_name("toscana").translations.create(:clean_name => 'tuscany', :name => 'Tuscany', :language => :en, :main_translation => true)

    Vote.vote_this(p4, "vote_1", u1)

    Tag.all.size.should == 7
  end
end
describe Vote do

  before(:each) do
    
    I18n.locale = :en

    @world = Tag.new()
    @world.id = 1
    @world.name = "World"
    @world.clean_name = "world"
    @world.level = 0
    @world.bounds = "-20000000 000000000 50000000 360000000"
    @world.save!

    @user_1 = User.new
    @user_1.password = "Secret"
    @user_1.email    = "user@example.com"
    @user_1.username = "Pippo"
    @user_1.save!

    @post_1 = Post.new
    @post_1.prepare_for_editing
    @post_1.title       = "Title 1"
    @post_1.description = "Description 1"
    @post_1.tag_names   = "Red, Yellow"
    @post_1.save!
    
  end

  it "Should set the view of the post to one" do
    Vote.vote_this(@post_1, nil, @user_1)
    @post_1.count_views.should == 1
  end

  it "Should still counting 1 also voting twice" do
    Vote.vote_this(@post_1, nil, @user_1)
    Vote.vote_this(@post_1, nil, @user_1)
    @post_1.count_views.should == 1
  end

  it "Should set the like counter to 1 if voted 'like'" do
    Vote.vote_this(@post_1, "vote_1", @user_1)
    @post_1.count_vote_1.should == 1
  end

  it "Should set the other_1 counter to 1 if voted 'other_1'" do
    Vote.vote_this(@post_1, "vote_2", @user_1)
    @post_1.count_vote_2.should == 1
  end

  it "Should set the other_1 counter to 0 if voted 'other_1' twice" do
    Vote.vote_this(@post_1, "vote_2", @user_1)
    Vote.vote_this(@post_1, "vote_2", @user_1)
    @post_1.count_vote_2.should == 0
  end

  after(:all) do
    Post.delete_all
    Tag.delete_all
    Tagging.delete_all
    Vote.delete_all
    User.delete_all
  end

end

