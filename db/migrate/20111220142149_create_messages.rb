class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer     :website_id
      t.references  :user                             # Sender
      t.references  :recipient, :polymorphic => true  # Recipient
      t.text        :recipient_list # In case the message is sent to a post, here there will be the list of volonteer id at that time, comma separated
      t.string      :to_type  # Can be User, but can also be Post (in this case it goes to all the user that volonteer for certain idea)
      t.text        :body
      t.string      :status
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end

