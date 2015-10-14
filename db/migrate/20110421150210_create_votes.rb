class CreateVotes < ActiveRecord::Migration

  def self.up
    create_table :votes do |t|
      t.references :user
      t.references :votable, :polymorphic => true
      t.integer    :votable_website_id  # Redondant field
      t.boolean    :votable_visible     # Redondant field
      t.boolean    :user_visible        # Redondant field

      t.integer    :vote_1
      t.integer    :vote_2
      t.integer    :vote_3
      t.integer    :vote_4

      t.integer    :edited        # In case the user edited this post/comment
      t.integer    :commented     # In case the user commented this post
      t.integer    :owner         # The user own this post/comment
      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end

end

