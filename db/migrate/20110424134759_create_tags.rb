# encoding: UTF-8
class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string     :name
      t.string     :clean_name      
      t.integer    :child_of_tag_id
      t.integer    :translation_of_tag_id
      t.string     :main_translation
      t.string     :status
      t.integer    :level
      t.string     :bounds
      t.string     :language
      t.string     :wikipedia_name
    end
    add_index :tags, :child_of_tag_id
    add_index :tags, :translation_of_tag_id
    world = Tag.create(:name => "World", :clean_name => "world", :level => 0, :bounds => "-20000000 000000000 50000000 360000000")

    world.translations.create(:clean_name => '世界', :name => '世界', :language => :ja, :main_translation => true)
    world.translations.create(:clean_name => '世界', :name => '世界', :language => :zh, :main_translation => true)
    world.translations.create(:clean_name => '全球', :name => '全球', :language => :ch, :main_translation => true)
    world.translations.create(:clean_name => '세계', :name => '세계', :language => :sk, :main_translation => true)
    world.translations.create(:clean_name => 'عالم',   :name => 'عالم',   :language => :ar, :main_translation => true)
    world.translations.create(:clean_name => 'мир',    :name => 'мир',    :language => :ru, :main_translation => true)
    world.translations.create(:clean_name => 'κόσμος', :name => 'κόσμος', :language => :gr, :main_translation => true)
    world.translations.create(:clean_name => 'mondo',  :name => 'Mondo',  :language => :it, :main_translation => true)
    world.translations.create(:clean_name => 'welt',   :name => 'Welt',   :language => :de, :main_translation => true)
    world.translations.create(:clean_name => 'monde',  :name => 'Monde',  :language => :fr, :main_translation => true)
    world.translations.create(:clean_name => 'mundo',  :name => 'Mundo',  :language => :sp, :main_translation => true)
    world.translations.create(:clean_name => 'mundo',  :name => 'Mundo',  :language => :pr, :main_translation => true)
  end

  def self.down
    drop_table :tags
  end
end


