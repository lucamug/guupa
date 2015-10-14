require 'rubygems'
Gem.clear_paths

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

### From http://blog.joeygeiger.com/2010/05/17/i-beat-dreamhost-how-to-really-get-rails-3-bundler-and-dreamhost-working/
if File.exist?(File.expand_path('../../Gemfile', __FILE__))
  require 'bundler'
  Bundler.setup
end
###

# require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

#require 'yaml'
#YAML::ENGINE.yamler= 'syck'
