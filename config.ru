# This file is used by Rack-based servers to start the application.

aaa
bbb
ccc
1/0

ENV['GEM_HOME'] = '/home/guupa/.gems'
# ENV['GEM_PATH'] = '$GEM_HOME:/usr/lib/ruby/gems/1.8'
ENV['GEM_PATH'] = '$GEM_HOME'

#require 'rubygems'
#Gem.clear_paths
require ::File.expand_path('../config/environment',  __FILE__)
run Guupa::Application
