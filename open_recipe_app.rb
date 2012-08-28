APP_ROOT = File.dirname(__FILE__)

require 'sinatra/base'
require 'haml'
require 'koala'
require 'logger'
require 'active_record'
require 'active_support/all'  # added for Time.zone support below

# register your app at facebook to get these codes
APP_ID = 435425809841072 # the app's id
APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

# testing at http://ppp167-251-9.static.internode.on.net:5000/
# production tests at http://open-recipe.herokuapp.com
SITE_URL = 'http://ppp167-251-9.static.internode.on.net:5000/' # your app site url

# don't change this without changing the callback route below.
CALLBACK_URL = SITE_URL + 'callback'

class OpenRecipeApp < Sinatra::Application

	include Koala

	set :root, APP_ROOT
  set :name, 'Open Recipe'
  set :tagline, 'Food with Friends'
  set :short_name, 'open-recipe'
  set :owner, 'Amy and Dave'
  set :owner_website, 'http://open-recipe.heroku.com'
  set :notification_email, 'davesag@gmail.com'
  set :no_reply_email, 'davesag+no_reply@gmail.com'
  set :no_reply_identity, 'OR Bot'
  set :author, 'Dave Sag'
  set :author_email, 'davesag@gmail.com'
  set :description, 'Open Recipe is a Facebook app for sharing and discovering recipes with your friends.'
  set :keywords, 'recipe, food, eating, drinking, cocktails, meals, restuarants'
  set :root, File.dirname(__FILE__)
  set :models, Proc.new { root && File.join(root, 'models') }
  set :haml, { :format => :html5 }

	enable :sessions, :logging, :show_exceptions

  @graph = nil               # the facebook graph is reloaded on each request in the before method.
  @active_user = nil         # the active user is reloaded on each request in the before method.

  class << self
    def load_models
      if !@models_are_loaded
        raise "No models folder found at #{models}" unless File.directory? models
        Dir.glob("#{models}/**.rb").sort.each { |m| require m }
        @models_are_loaded = true
      end
    end
  end

  # TIMEZONES
  # @todo: On Heroku you need to set the TZ environment variable. You won't want to keep using the Rails time zones
  # but instead use the official abbreviations http://www.timeanddate.com/library/abbreviations/timezones

  configure :test do
    set :environment, :test
    set :protection, :except => [:remote_token, :frame_options]
    set :haml, {:format => :html5}
    set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
    mime_type :'x-icon', 'image/x-icon'

    enable :logging

    Time.zone = "UTC"
    ActiveRecord::Base.time_zone_aware_attributes = true
    ActiveRecord::Base.default_timezone = :utc

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::DEBUG      #not interested in database stuff right now.

    ActiveRecord::Base.establish_connection (ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db/test.sqlite3")

    @models_are_loaded = false
    load_models

    puts "Open Recipe is running in TEST MODE."
  end

  configure :development do
    set :environment, :development
    set :protection, :except => [:remote_token, :frame_options]
    set :haml, {:format => :html5}
    set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
    mime_type :'x-icon', 'image/x-icon'

    enable :logging

    Time.zone = "UTC"
    ActiveRecord::Base.time_zone_aware_attributes = true
    ActiveRecord::Base.default_timezone = :utc

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::WARN      #not interested in database stuff right now.

    ActiveRecord::Base.establish_connection (ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3")

    @models_are_loaded = false
    load_models

    puts "Open Recipe is running."
  end

  configure :production do
    set :environment, :production
    set :protection, :except => [:remote_token, :frame_options]
    set :haml, {:format => :html5}
    set :session_secret, ENV['SESSION_SECRET'] ||= 'seriously super secret'
    mime_type :'x-icon', 'image/x-icon'

    enable :logging

    Time.zone = "UTC"
    ActiveRecord::Base.time_zone_aware_attributes = true
    ActiveRecord::Base.default_timezone = :utc

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::WARN      #not interested in database stuff right now.

    ActiveRecord::Base.establish_connection (ENV['DATABASE_URL'])

    @models_are_loaded = false
    load_models

    puts "Open Recipe is running."
  end


  helpers do
  
    # this is where the magic happens. Prepare local page data for the Open Recipe's homepage.
    # Could do some stuff with facebook here, for example:
    # graph = Koala::Facebook::API.new(session['access_token'])
    # publish to your wall (if you have the permissions)
    # graph.put_wall_post("I'm posting from my new cool app!")
    # or publish to someone else (if you have the permissions too ;) )
    # graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
    def homepage
      @recipes = []
      @recipes << {:title => 'Delicious Duck in Orange Sauce', :url => 'http://about.me/davesag'}
      @recipes << {:title => 'Goat Cheese Pankakes', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
      @recipes << {:title => 'Fudge Soup', :url => 'http://www.ruby-lang.org/en/documentation/quickstart/'}
    end

    def menu_item(title, href)
      menu_item = {:title => title}
      page_name = request.path_info.downcase
      if page_name == href
        menu_item[:selected] = true
      else
        menu_item[:href] = href
      end
      return menu_item
    end

    # returns an array of hashes of the following
    # {:title => 'menu title', :href => '/something'}
    # or the default {:title => 'menu title', :selected => true} implying selected is true and no link.
    def navigation
      menu = []
      menu << menu_item('Dashboard', '/')
      menu << menu_item('About', '/about')
      menu << menu_item('Browse', '/browse') if logged_in?
      menu << menu_item('Settings', '/settings') if logged_in?
      menu << menu_item('FAQs', '/faqs')
      menu << menu_item('Privacy', '/privacy')
      menu << menu_item('Terms', '/terms')
      return menu
    end

    def logged_in?
      return session['access_token'] != nil
    end

    def active_user
      return nil unless logged_in?
      load_active_user
      return @active_user
    end
  end

  def load_active_user
    return unless @active_user == nil
    return unless logged_in?
    
    @graph = Koala::Facebook::API.new(session['access_token']) if @graph == nil
    me = @graph.get_object('me')
    @active_user = User.where(:username => me['username']).first_or_create(:remote_id => me['id'].to_i)
    @active_user.update_from_facebook me
    @active_user.save
    
    # get current location.
    location = me['location']
    logger.debug "User location is #{location['name'] || 'not specified'}"
    if location != nil
      location = @graph.get_object(location['id'])
      logger.debug "User location details: #{location.inspect}"
      category_name = location['category']
      logger.debug "#{location['name']} has category #{category_name}."
    end
  end

  before do
    logger.level = Logger::DEBUG
    logger.debug "---------------------------------------------------------"
    logger.debug "---------------------------------------------------------"
    logger.debug "Handling request from host #{request.env['REMOTE_HOST']}"
    logger.debug "Session ID: #{session['session_id']}"
    logger.debug "---------------------------------------------------------"

    load_active_user
  end

  after do
    logger.debug "---------------------------------------------------------"
    logger.debug "Session ID: #{session['session_id']}"
    logger.debug "Completed request from host #{request.env['REMOTE_HOST']}"
    logger.debug "---------------------------------------------------------"
    logger.debug "---------------------------------------------------------"
  end

	post '/' do
    homepage
    haml :index
	end

	get '/' do
    homepage
    haml :index
	end

	get '/login' do
		# generate a new oauth object with your app data and your callback url
		session['oauth'] = Facebook::OAuth.new(APP_ID, APP_CODE, CALLBACK_URL)
		logger.debug "Set session['oauth'] : #{session['oauth'].class}"
    logger.debug "Session id: #{session['session_id']}"
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code(
		      :permissions => ["read_friendlists", "publish_stream","email","user_location",
		      "user_likes", "user_checkins", "user_photos"])
	end

	get '/logout' do
	  logger.debug "Logout from session #{session['session_id']}"
		session['oauth'] = nil
		session['access_token'] = nil
		@active_user = nil
		@graph = nil
		redirect '/'
	end

	#method to handle the redirect from facebook back to you
	get '/callback' do
		#get the access token from facebook with your code
		if session['oauth'] == nil
		  logger.error "Could not find oauth key in session #{session['session_id']}"
    else
      session['access_token'] = session['oauth'].get_access_token(params[:code])
      load_active_user
		end
		redirect '/'
	end

  get '/privacy' do
    haml :privacy
  end

  get '/terms' do
    haml :terms
  end

  get '/support' do
    haml :support
  end

  get '/about' do
    haml :about
  end

  get '/browse' do
    redirect '/' unless logged_in?
    haml :browse
  end

  get '/settings' do
    redirect '/' unless logged_in?
    haml :settings
  end

  get '/faqs' do
    redirect '/' unless logged_in?
    haml :faqs
  end

end
