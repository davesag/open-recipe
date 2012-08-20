require 'sinatra'
require 'haml'
require 'omniauth-facebook'

enable :sessions, :logging, :show_exceptions

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
    @recipes = []
    @recipes << {:title => 'Delicious Duck in Orange Sauce', :url => 'http://about.me/davesag'}
    @recipes << {:title => 'Goat Cheese Pankakes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
    @recipes << {:title => 'Fudge Soup', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
  end

  # true if the user has logged in with their Facebook credentials.
  def logged_in?
    if session[:fb_auth] == nil || session[:fb_auth].empty?
      logger.info "No Facebook user in session."
      return false
    else
      a = session[:fb_auth]
      logger.info "a) #{a.keys.inspect}" # ["provider", "uid", "info", "credentials", "extra"]
      logger.info "Provider: '#{a[:provider]}'" # facebook
      logger.info "UUID: '#{a[:uid]}'" # 677015415
      logger.info "Info: '#{a[:info].keys.inspect}'" # ["nickname", "email", "name", "first_name", "last_name", "image", "description", "urls", "verified"]
      logger.info "  Nickname: #{a[:info][:nickname]}"
      logger.info "  Email: #{a[:info][:email]}"
      logger.info "  Name: #{a[:info][:name]}"
      logger.info "  First Name: #{a[:info][:first_name]}"
      logger.info "  Last Name: #{a[:info][:last_name]}"
      logger.info "  Image URL: #{a[:info][:image]}"
      logger.info "  Description: #{a[:info][:description]}"
      logger.info "  URLs: #{a[:info][:urls].keys.inspect}"
      logger.info "  Verified: #{a[:info][:verified]}"
      logger.info "Credentials: '#{a[:credentials].keys.inspect}'" # ["token", "expires_at", "expires"]
      logger.info "  Token: '#{a[:credentials][:token].inspect}'"
      logger.info "  Expires At: '#{a[:credentials][:expires_at].inspect}'"
      logger.info "  Expires: '#{a[:credentials][:expires].inspect}'" # true
      logger.info "Extra: '#{a[:extra].keys.inspect}'" # ["raw_info"]
      logger.info "  Raw Info: '#{a[:extra][:raw_info].keys.inspect}'" # ["id", "name", "first_name", "last_name", "link", "username", "bio", "quotes", "sports", "inspirational_people", "gender", "email", "timezone", "locale", "languages", "verified", "updated_time"]
      
      u = a[:info]
      if u == nil || u.empty?
        logger.error "Could not access user_info from data returned by Facebook."
        return false
      end
      n = u[:first_name]
      if n == nil || n.empty?
        logger.error "Could not access first_name from credentials returned by Facebook." 
        return false
      end
      logger.info "Discovered Facebook user #{n} in session."
      return true
    end
  end
  
  # clears all the facebook tokens out
  def clear_session
    logger.info "Clearing session of Facebook tokens."
    session[:fb_auth] = nil
    session[:fb_token] = nil
    session[:fb_error] = nil
  end

end

# web requests will come in here.
get '/' do
    logger.info "Direct Web Request detected.  Developing a response."

    homepage
    haml :index
end

# facebook app requests will come in here.
post '/' do
    logger.info "Facebook AppRequest detected.  Developing a response."

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
