class Connection < ActiveRecord::Base
  belongs_to :user
  attr_accessor   :email, :password, :remember_me
  attr_accessible :email, :password, :remember_me
  email_regex    = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_presence_of :password, :on => :create
  validates :email, :presence   => true,
                    :format     => { :with => email_regex }
end

