module PostHelper

  def facebook_button(url, text)
    url = "http://www.facebook.com/sharer.php?u=#{CGI.escape(url)}&t=#{CGI.escape(text)}"
    return link_to(image_tag("facebook.png"), url, :target => "_blank", :title => t(:share_on_facebook))
  end

  def twitter_button(url, text)
    url = "http://twitter.com/share?url=#{CGI.escape(url)}&text=#{CGI.escape(text)}"
    return link_to(image_tag("twitter.png"), url, :target => "_blank", :title => t(:share_on_twitter))
  end

  def google_button(url, text)
    url = "https://plusone.google.com/_/+1/confirm?url=#{CGI.escape(url)}"
    return link_to(image_tag("gplus.png"), url, :target => "_blank", :title => t(:share_on_google))
  end

  def description_to_display(text)
    # Remove all tags except table
    text = sanitize(text, :tags => %W(table tr td))
    text.gsub!(/(http|https):\/\/[^\n ]*/) do |url|
      if youtube = /youtube.com\/watch\?v=([^& ]+)/.match(url)
        "<iframe class='youtube-player' type='text/html' width='440' height='300' src='http://www.youtube.com/embed/#{youtube[1]}' frameborder='0'></iframe>"
      else
        link_to url, url
      end
    end
    # Conver markdown into html
    text = RDiscount.new(text).to_html
    text = text.html_safe
  end
end
