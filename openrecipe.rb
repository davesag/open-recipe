require 'sinatra'
require 'haml'
require 'omniauth-facebook'
require 'data_mapper'
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

  class User
    include DataMapper::Resource
    property :id, Serial
    property :name, String, :length => 1..75
    property :sex, String, :length => 1..7
    property :first_name, String, :length => 1..25
    property :last_name, String, :length => 1..25
    property :username, String, :length => 1..25, :unique => true
    property :email, String, :length => 1..75
    property :authentication_token, String, :length => 1..255
    property :remote_id, String, :length => 1..255
    property :profile_picture_url, String, :length => 1..255
  
    def update_from_facebook?(fb_auth)
  #    logger.info "a) #{fb_auth.keys.inspect}" # ["provider", "uid", "info", "credentials", "extra"]
  #    logger.info "Provider: '#{fb_auth[:provider]}'" # facebook
  #    logger.info "UUID: '#{fb_auth[:uid]}'" # 677015415
  #    logger.info "Info: '#{fb_auth[:info].keys.inspect}'" # ["nickname", "email", "name", "first_name", "last_name", "image", "description", "urls", "verified"]
  #    logger.info "  Nickname: #{fb_auth[:info][:nickname]}"
  #    logger.info "  Email: #{fb_auth[:info][:email]}"
  #    logger.info "  Name: #{fb_auth[:info][:name]}"
  #    logger.info "  First Name: #{fb_auth[:info][:first_name]}"
  #    logger.info "  Last Name: #{fb_auth[:info][:last_name]}"
  #    logger.info "  Image URL: #{fb_auth[:info][:image]}"
  #    logger.info "  Description: #{fb_auth[:info][:description]}"
  #    logger.info "  URLs: #{fb_auth[:info][:urls].keys.inspect}"
  #    logger.info "  Verified: #{fb_auth[:info][:verified]}"
  #    logger.info "Credentials: '#{fb_auth[:credentials].keys.inspect}'" # ["token", "expires_at", "expires"]
  #    logger.info "  Token: '#{fb_auth[:credentials][:token].inspect}'"
  #    logger.info "  Expires At: '#{fb_auth[:credentials][:expires_at].inspect}'"
  #    logger.info "  Expires: '#{fb_auth[:credentials][:expires].inspect}'" # true
  #    logger.info "Extra: '#{fb_auth[:extra].keys.inspect}'" # ["raw_info"]
  #    logger.info "  Raw Info: '#{fb_auth[:extra][:raw_info].keys.inspect}'" # ["id", "name", "first_name", "last_name", "link", "username", "bio", "quotes", "sports", "inspirational_people", "gender", "email", "timezone", "locale", "languages", "verified", "updated_time"]
      
      inf = fb_auth[:info]
      if inf == nil || inf.empty?
        puts "Could not access user_info from data returned by Facebook."
        return false
      end
      n = inf[:name]
      if n == nil || n.empty?
        puts "Could not access name from credentials returned by Facebook." 
        return false
      end
      puts "Loaded Facebook user #{n}."
      if 'true' != inf[:verified].to_s
        puts "But alas Facebook user #{n} is unverified by Facebook."
        puts "verified = '#{inf[:verified]}'"
        return false
      end
      
      self.name = n
      self.first_name = inf[:first_name]
      self.last_name = inf[:last_name]
      self.username = fb_auth[:extra][:raw_info][:username]
      self.email = fb_auth[:extra][:raw_info][:email]
      self.sex = fb_auth[:extra][:raw_info][:gender]
      self.authentication_token = fb_auth[:credentials][:token]
      self.remote_id = fb_auth[:extra][:raw_info][:id]
      self.profile_picture_url = inf[:image]
      return true
    end
  
  end

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, (ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"))
  User.raise_on_save_failure = true  # while debugging.
  DataMapper.finalize
  DataMapper.auto_upgrade!
end

use OmniAuth::Builder do
#  puts "Checking with Facebook using ID #{APP_ID} and secret #{APP_SECRET}."
  provider :facebook, APP_ID, APP_SECRET, { :scope => 'email, status_update, publish_stream' }
end

before do
  logger.level = Logger::DEBUG
  logger.debug "Handling request."
  record_user
end

helpers do

  # this is where the magic happens. Prepare local page data for the Open Recipe's homepage.
  def homepage
    @recipes = []
    @recipes << {:title => 'Delicious Duck in Orange Sauce', :url => 'http://about.me/davesag'}
    @recipes << {:title => 'Goat Cheese Pankakes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
    @recipes << {:title => 'Fudge Soup', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
  end

  # save the user data to database.
  def record_user
    if session[:app_username] == nil
      logger.info "No username in session."
      return
    end
    logger.info "Found username '#{session[:app_username]}' in session."
    
    if session[:fb_auth] == nil
      logger.info "No Facebook data in session."
      return
    end
    
    @user = nil
    user = User.first_or_create(:username => session[:app_username])
    if !user.update_from_facebook?(session[:fb_auth])
      logger.info "Updating database with #{user.username}'s Facebook details failed."
      user = nil
      session[:app_username] == nil
      session[:fb_error] = "Updating database with #{user.username}'s Facebook details failed."
      return
    end
  
    logger.info "About to attempt to save #{user.username}'s data."
    user.save # will raise an exception if this fails
    logger.info "Saved user #{user.username} (#{user.first_name} #{user.last_name}) to our database."
    session[:app_username] = user.username
    @user = user
    session[:fb_error] = nil
  end

  # true if the user has logged in with their Facebook credentials.
  def logged_in?
    return false if session[:fb_auth] == nil || session[:fb_auth].empty?
    if session[:app_username] == nil
      logger.info "Found Facebook user #{session[:fb_auth][:extra][:raw_info][:username]} but there was no corresponding User object stored in the session."
      return false
    end
    if @user == nil
      logger.info "Found App User #{session[:app_username]} in the session but no actual user object was found."
      return false
    end
    logger.info "User #{@user.username} is logged in."
    return true
  end
  
  def active_user
    return nil unless logged_in?
    return @user if @user != nil
    
    logger.info "Trying to find user with username #{session[:app_username]}"
    @user = User.first(:username => session[:app_username])
    logger.info "Returning user #{@user.username} (#{@user.first_name} #{@user.last_name})." if @user
    logger.error "No User Found in Database." unless @user
    return @user
  end

  # clears all the facebook tokens out
  def clear_session
    logger.info "Clearing session of Facebook tokens."
    session[:fb_auth] = nil
    session[:fb_token] = nil
    session[:fb_error] = nil
    session[:app_username] = nil
    @user = nil
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

  session[:fb_auth] = request.env['omniauth.auth']
  session[:fb_token] = session[:fb_auth][:credentials][:token]
  
  # write the data to DB if needs be.
  session[:app_username] = session[:fb_auth][:extra][:raw_info][:username]
  logger.info "Stored Authenticated Facebook user #{session[:app_username]}'s username in the session."

  record_user

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
