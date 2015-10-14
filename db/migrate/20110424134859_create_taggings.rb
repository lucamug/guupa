class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.references :tag
      t.references :taggable, :polymorphic => true
      t.integer    :taggable_website_id   # Redondant field
      t.boolean    :taggable_visible      # Redondant field
      t.boolean    :taggable_is_a_father  # Redondant field
      t.boolean    :tag_visible           # Redondant field
      t.integer    :tag_child_of_tag_id   # Redondant field
    end
  end

  def self.down
    drop_table :taggings
  end
end

