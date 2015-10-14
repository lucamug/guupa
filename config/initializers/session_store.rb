# Be sure to restart your server when you modify this file.

#Auth::Application.config.session_store :cookie_store, key: 'g'

if Rails.env == 'production'
 Guupa::Application.config.session_store :cookie_store, :key => 'g' # , :domain => '.guupa.com'
elsif Rails.env == 'development'
  Guupa::Application.config.session_store :cookie_store, :key => 'g' # , :domain => '.lvh.me'
else
  # I don't know why, but tests fails with lvh.me. Probably there is somewhere
  # else in the configuration that I need to change example.com to lvh.com
  Guupa::Application.config.session_store :cookie_store, :key => 'g', :domain => 'www.example.com'
end




