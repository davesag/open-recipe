require 'openrecipe'
require 'rack/protection'

# use Rack::Protection, :except => [:remote_token, :frame_options]
set :protection, :except => [:remote_token, :frame_options]
run Sinatra::Application
