require 'openrecipe' #this is to load openrecipe.rb

set :protection, :except => [:remote_token, :frame_options]
run Sinatra::Application
