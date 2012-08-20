require 'sinatra'
require 'omniauth-facebook'

enable :sessions

#Here you have to put your own Application ID and Secret
APP_ID = "153304591365687"
APP_SECRET = "7a7663099ccb62f180d985ba1252a3e2"

use OmniAuth::Builder do
  puts "Checking with Facebook using ID #{APP_ID}."
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
  puts "Provider established."
end

# this is where the magic happens. Present the Open Recipe's homepage.
get '/' do

    puts "Request detected.  Developing a response."

    @articles = []
    @articles << {:title => 'Deploying Rack-based apps in Heroku', :url => 'http://docs.heroku.com/rack'}
    @articles << {:title => 'Learn Ruby in twenty minutes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}

    haml :index
end

get '/auth/facebook/callback' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use this site you must grant us permission to have access to some of your Facebook data<br />'
  redirect '/'
end

get '/logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
