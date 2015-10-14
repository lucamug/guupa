class Comment < ActiveRecord::Base
  has_paper_trail :ignore => [:count_votes]  
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  has_many   :votes, :as => :votable

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_presence_of :body, :commentable_website_id, :commentable_type
  validates :title,
    :format => {:with => /^$/} # This is to avoid spambots to submit forms. I hope they will fill the title too...

  validates :temporary_email, 
    :format      => {:with => email_regex },
    :allow_blank => true

  attr_accessor :temporary_email, :title, :from_action, :progress

  before_validation :get_the_website_id_from_the_commentable
  before_create :default_values

  scope :visible, lambda { where('status = ? or status = ?', :NEW, :APPROVED) } 

  def get_the_website_id_from_the_commentable
    if self.commentable && self.commentable.respond_to?(:website_id)
      self.commentable_website_id = self.commentable.website_id
    end
  end
    
  def default_values
    self.count_vote_1 ||= 0
    self.status = "NEW"
  end  
end
