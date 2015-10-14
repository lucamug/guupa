class Message < ActiveRecord::Base
  # belongs_to :sender,    :class_name => "User"
  belongs_to :sender, :foreign_key => "user_id", :class_name => "User"
  belongs_to :recipient,                       :polymorphic => true
  validates_presence_of :body
  attr_accessor :messages_token
end

