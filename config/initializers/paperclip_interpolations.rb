Paperclip.interpolates('my_sub_1') do |attachment, style| return attachment.hash(style)[0,1] end
Paperclip.interpolates('my_sub_2') do |attachment, style| return attachment.hash(style)[0,2] end
Paperclip.interpolates('my_extension') do |attachment, style_name|
  ext = extension(attachment, style_name).to_s
  ext.downcase!
  ext.gsub!(/jpeg/, "jpg")
  return ext.to_sym
end

