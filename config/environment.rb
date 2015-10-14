# Load the rails application

# From http://blog.joeygeiger.com/2010/05/17/i-beat-dreamhost-how-to-really-get-rails-3-bundler-and-dreamhost-working/
# Load the rails application
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ':/usr/lib/ruby/gems/1.8'
require File.expand_path('../application', __FILE__)
####

# Trying to add these lines ot fix dreamhost problem 2013.09.06
require 'rubygems'
require 'rubygems/gem_runner'
# ENV['GEM_PATH'] = '/home/guupa/.gems:/usr/lib/ruby/gems/1.8'
# End of lines

require File.expand_path('../application', __FILE__)

# Initialize the rails application
Guupa::Application.initialize!

# Haml::Template.options[:format]      = :html5
# Haml::Template.options[:escape_html] = false

Haml::Template::options[:ugly] = true
if ENV['RAILS_ENV'] == 'production'
  Haml::Template::options[:ugly] = true
end

