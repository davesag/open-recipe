require 'sinatra'
require 'haml'
require 'omniauth-facebook'
require 'logger'

# testing at http://ppp167-251-9.static.internode.on.net:5000/
# production tests at http://open-recipe.herokuapp.com

enable :sessions, :logging, :show_exceptions

#Here you have to put your own Application ID and Secret
APP_ID = "435425809841072"
APP_SECRET = "b8c359ffe13e3ed7e90670e4bb5ec5bd"

configure do
  set :protection, :except => [:remote_token, :frame_options]
  set :haml, {:format => :html5}

end

use OmniAuth::Builder do
#  puts "Checking with Facebook using ID #{APP_ID} and secret #{APP_SECRET}."
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
end

before do
  logger.level = Logger::DEBUG
  logger.debug "Handling request."
end

helpers do

  # this is where the magic happens. Prepare local page data for the Open Recipe's homepage.
  def homepage
    @recipes = []
    @recipes << {:title => 'Delicious Duck in Orange Sauce', :url => 'http://about.me/davesag'}
    @recipes << {:title => 'Goat Cheese Pankakes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
    @recipes << {:title => 'Fudge Soup', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
  end

  # true if the user has logged in with their Facebook credentials.
  def logged_in?
    return false if session[:fb_auth] == nil || session[:fb_auth].empty?
    if session[:app_username] == nil
      logger.debug "Found Facebook user #{session[:fb_auth][:extra][:raw_info][:username]} but there was no corresponding User object stored in the session."
      return false
    end
    logger.debug "User #{session[:app_username]} is logged in."
    return true
  end
  
  def active_user
    return nil unless logged_in?
    return session[:app_username]
  end

  # clears all the facebook tokens out
  def clear_session
    logger.debug "Clearing session of Facebook tokens."
    session[:fb_auth] = nil
    session[:fb_token] = nil
    session[:fb_error] = nil
    session[:app_username] = nil
  end

end

# web requests will come in here.
get '/' do
    logger.debug "Direct Web Request detected.  Developing a response."

    homepage
    haml :index
end

# facebook app requests will come in here.
post '/' do
    logger.debug "Facebook AppRequest detected.  Developing a response."

    homepage
    haml :index
end

# handler for the facebook authentication api.
get '/auth/facebook/callback' do

  session[:fb_auth] = request.env['omniauth.auth']
  session[:fb_token] = session[:fb_auth][:credentials][:token]
  
  # write the data to DB if needs be.
  session[:app_username] = session[:fb_auth][:extra][:raw_info][:username]
  logger.debug "Stored Authenticated Facebook user #{session[:app_username]}'s username in the session."

  redirect '/'
end

# handler for the facebook authentication api.
get '/auth/failure' do
  clear_session
  session[:fb_error] = 'In order to use this site you must grant us permission to have access to some of your Facebook data<br />'
  redirect '/'
end

# handler for the facebook authentication api.
get '/logout' do
  clear_session
  redirect '/'
end
