class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.references :user
      t.string     :session_id
      t.string     :auth_token
      t.string     :temporary_email
      t.text       :ip
      t.text       :agent
      t.boolean    :remember_me
      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end

