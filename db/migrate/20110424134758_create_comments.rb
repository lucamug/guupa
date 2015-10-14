class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :user
      t.references :commentable, :polymorphic => true
      t.integer    :commentable_website_id  # Redondant field
      t.text       :body
      t.integer    :count_vote_1
      t.string     :status       # ERROR, ACTIVE, DRAFT, DELETED, HIDDEN, etc.
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end

