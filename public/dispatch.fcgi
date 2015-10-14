#!/usr/bin/ruby

# Dreamhost clears environment variables when calling dispatch.fcgi, so set them here 
ENV['RAILS_ENV'] ||= 'production'
ENV['HOME'] ||= `echo ~`.strip
ENV['GEM_HOME'] = File.expand_path('~/.gems')
ENV['GEM_PATH'] = File.expand_path('~/.gems') + ":" + '/usr/lib/ruby/gems/1.8'

require 'rubygems'
Gem.clear_paths
require 'fcgi'

require File.join(File.dirname(__FILE__), '../config/environment.rb')

class Rack::PathInfoRewriter
 def initialize(app)
   @app = app
 end

 def call(env)
   env.delete('SCRIPT_NAME')
   parts = env['REQUEST_URI'].split('?')
   env['PATH_INFO'] = parts[0]
   env['QUERY_STRING'] = parts[1].to_s
   @app.call(env)
 end
end

Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(Guupa::Application)  # REPLACE X WITH YOUR APPLICATION'S NAME (found in config/application.rb)