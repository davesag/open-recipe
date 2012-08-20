require 'openrecipe' #this is to load openrecipe.rb
require 'rack/protection'

use Rack::Protection, :except => [:remote_token, :frame_options]
run Sinatra::Application
