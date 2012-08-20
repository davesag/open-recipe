require 'sinatra'
require 'haml'
require 'omniauth-facebook'

enable :sessions

#Here you have to put your own Application ID and Secret
APP_ID = "435425809841072"
APP_SECRET = "b8c359ffe13e3ed7e90670e4bb5ec5bd"

configure do
    set :protection, :except => [:remote_token, :frame_options]
end

use OmniAuth::Builder do
  puts "Checking with Facebook using ID #{APP_ID}."
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
  puts "Provider established."
end

# this is where the magic happens. Present the Open Recipe's homepage.

helpers do

  # this is where the magic happens. Prepare local page data for the Open Recipe's homepage.
  def homepage
    @articles = []
    @articles << {:title => 'Deploying Rack-based apps in Heroku', :url => 'http://docs.heroku.com/rack'}
    @articles << {:title => 'Learn Ruby in twenty minutes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
  end

  def logged_in
    return true unless session['fb_auth'] == nil || session['fb_auth'].empty?
    return false
  end

end

# web requests will come in here.
get '/' do
    puts "Direct Web Request detected.  Developing a response."

    homepage
    haml :index
end

# facebook app requests will come in here.
post '/' do
    puts "Facebook AppRequest detected.  Developing a response."

    homepage
    haml :index
end

# handler for the facebook authentication api.
get '/auth/facebook/callback' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

# handler for the facebook authentication api.
get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use this site you must grant us permission to have access to some of your Facebook data<br />'
  redirect '/'
end

# handler for the facebook authentication api.
get '/logout' do
  clear_session
  redirect '/'
end

# handler for the facebook authentication api.
def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
