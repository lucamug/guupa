class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :attachable, :polymorphic => true
  has_many   :comments,    :as => :commentable
  has_many   :votes,       :as => :votable
  has_many   :taggings,    :as => :taggable
  has_many   :tags,        :through => :taggings
  # For more details about interpolation in paper clip, see the files
  #   /config/initializers/paperclip_interpolations.rb
  # and also...
  #   http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads
  #   https://github.com/thoughtbot/paperclip/pull/416
  #   https://github.com/thoughtbot/paperclip/wiki/Interpolations
  #   http://www.viget.com/extend/paperclip-custom-interpolation/
  has_attached_file :document,
    # Using the following style, the thumbnails are always cropped in the middle
    # but for vertical pictures is better to crop the bottom part and keep the top.
    # :styles      => { :large => ["900x900>", :jpg], :thumb => ["240x180#", :jpg] },
    # With the following two lines, the crop happen at the top left. For vertical
    # pictures is good put for panorama it would crop the left part. It is ok
    # Because there will be few panoramas compared to vertical pictures.
    # From http://stackoverflow.com/questions/4578603/how-do-you-crop-a-specific-area-with-paperclip-in-rails-3
    :styles      => { :large => ["900x900>", :jpg], :thumb => ["240x180^", :jpg] },
    :convert_options => { :thumb => "-crop '240x180+0+0'" },
    # Documentation for the above line here: http://www.imagemagick.org/script/command-line-processing.php#geometry
    #
    # Extract:
    #
    # widthxheight>	Change as per widthxheight but only if an image dimension exceeds a specified dimension.
    #
    # The # mark is handled by paperclip and not imagemagik
    #
    :path        => ':rails_root/public/system/:attachment/:style/:my_sub_1/:my_sub_2/:hash.:my_extension',
    :url         =>                   '/system/:attachment/:style/:my_sub_1/:my_sub_2/:hash.:my_extension',
    :hash_secret => '3fj6ft7hsscswewwe3h5fvbruddfhjkerlrtohe5r46'
  # For testing attachments:
  # a = Attachment.create(:document => File.open('/home/luca/Desktop/world heritage/step_5_output_images/0590.dd_KHAOYAI.JPG', 'rb'))
  attr_accessor :remove
  after_initialize :default_values
  scope :not_removed, lambda { where('attachments.status != ?', :REMOVED) } 
  scope :visible, lambda { where('status = ? or status = ?', :NEW, :APPROVED) } 

  def default_values
    self.status      ||= "NEW"
  end
end

