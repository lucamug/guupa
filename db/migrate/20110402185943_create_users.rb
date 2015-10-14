class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :encrypted_email
      t.string :temporary_email      # In case this is a "Temporary User"
      t.string :password_hash
      t.string :password_salt
      t.string :locale          # Language

      t.string :subtype          

      t.string :auth_token
      
      t.string   :password_reset_token
      t.datetime :password_reset_sent_at

      t.string   :email_confirmation_token
      t.boolean  :email_confirmed

      t.string   :messages_token # Token to exchange messages between users

      t.string :first           # Name
      t.string :middle
      t.string :last
    
      t.string :status # GUEST       email and temporary_email are blank
                       # TEMPORARY   email is blank and temporary_email is not blank
                       # REGISTERED  email is not blank
                       # CONFIRMED
                       # HIDDEN
                       # DESTROYED
      
# def is_guest?      # Just connected but did not fill any temporary email
# def is_temporary?  # Guest and filled temporary email
# def is_registered? # Registered but email not confirmed
# def is_confirmed?  # Registered but email not confirmed

      t.string :username        # Must be unique
      
      t.timestamps
    end
#    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table :users
  end
end

