class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.references :user
      t.references :attachable,  :polymorphic => true
      t.string     :status
      t.string     :copyright
      t.string     :note

      # Following the fields for the plugin paperclip
      t.string    :document_file_name
      t.string    :document_content_type
      t.integer   :document_file_size
      t.datetime  :document_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end

