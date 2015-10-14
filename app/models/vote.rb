class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :votable, :polymorphic => true
  # attr_accessible :user_id, :likeability, :favorite # To avoid mass-assign something
  # after_initialize :default_values

  def self.all_votes_for_the_user(p = {})
    #
    # To test
    #
    # Vote.all_votes_for_the_user :user_id => 1, :website_id => 1
    #
    return nil if p[:user_id].blank?
    p[:website_id]   ||= 0  # GuuPa main site0
    votes = Vote.where(:user_id => p[:user_id])
    result = {
      :view    => [],
      :own     => [],
      :vote_1  => [],
      :vote_2  => [],
      :vote_3  => [],
      :vote_4  => [],
      :comment => [],
      :other_websites => {},
    }
    votes.each do |vote|
      # The "Post" condition here should be done differently. This way seems 
      # that only Post can be voted.
      if vote.votable_type == "Post"
        if vote.votable_website_id == p[:website_id]
          result[:view].push vote.votable_id
          result[:vote_1].push(vote.votable_id)  if vote.vote_1 == 1
          result[:vote_2].push(vote.votable_id)  if vote.vote_2 == 1
          result[:vote_3].push(vote.votable_id)  if vote.vote_3 == 1
          result[:vote_4].push(vote.votable_id)  if vote.vote_4 == 1
          result[:own].push(vote.votable_id)     if vote.owner == 1
          result[:comment].push(vote.votable_id) if vote.commented == 1
        else
          result[:other_websites][vote.votable_website_id] ||= 0
          result[:other_websites][vote.votable_website_id] += 1
        end
      end
    end
    return result         
    # Should I have another reduntant field here, "visibility"? and also "website?"
  end

  def default_values
    self.vote_1 ||= 0
    self.vote_2 ||= 0
    self.vote_3 ||= 0
    self.vote_4 ||= 0
  end

  def self.vote_this(votable, type_of_vote, user)
    Util.my_log("Vote#vote_this")    
    # type_of_vote can be: :like, :dislike, :other_1, :other_2, :other_3
    # for testing:
    # Vote.vote_this(Post.first, "like", User.first)
    vote = nil
    votable.default_values # This to be shure that counters are all set to zero if not already defined
    unless vote = votable.votes.find_by_user_id(user.id)
      # If the vote between the post and the user don't yet exsist, it creata a new
      # one and increase the view counting of the votable.
      vote = votable.votes.new(:user_id => user.id)
      votable.count_views = votable.count_views + 1
    end

    vote.default_values
    old_vote_1 = vote.vote_1
    old_vote_2 = vote.vote_2
    old_vote_3 = vote.vote_3
    old_vote_4 = vote.vote_4
    
    if type_of_vote == "vote_1"
      vote.vote_1 = ( vote.vote_1 == 1 ? 0 : 1 )
    elsif type_of_vote == "vote_2"
      vote.vote_2 = ( vote.vote_2 == 1 ? 0 : 1 )
    elsif type_of_vote == "vote_3"
      vote.vote_3 = ( vote.vote_3 == 1 ? 0 : 1 )
    elsif type_of_vote == "vote_4"
      vote.vote_4 = ( vote.vote_4 == 1 ? 0 : 1 )
    end

    votable.count_vote_1 -= old_vote_1 - vote.vote_1
    votable.count_vote_2 -= old_vote_2 - vote.vote_2
    votable.count_vote_3 -= old_vote_3 - vote.vote_3
    votable.count_vote_4 -= old_vote_4 - vote.vote_4

    vote.votable_visible    = votable.visible?
    vote.user_visible       = user.visible?
    vote.votable_website_id = votable.website_id
    vote.save
    votable.save
    return vote
  end  
end

