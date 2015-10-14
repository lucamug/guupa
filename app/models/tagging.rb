class Tagging < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :tag
  def self.tag_ids(taggable_ids, taggable_type)
    return Tagging.where(:taggable_id => taggable_ids, :taggable_type => taggable_type).select("tag_id").map{|item| item.tag_id}
  end
end

