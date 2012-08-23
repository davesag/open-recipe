APP_ROOT = File.dirname(__FILE__)

require 'sinatra'
require 'haml'
require 'koala'
require 'logger'

# register your app at facebook to get those infos
APP_ID = 435425809841072 # the app's id
APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

# testing at http://ppp167-251-9.static.internode.on.net:5000/
# production tests at http://open-recipe.herokuapp.com
SITE_URL = 'http://open-recipe.herokuapp.com/' # your app site url

# don't change this without changing the callback route below.
CALLBACK_URL = SITE_URL + 'callback'

class OpenRecipeApp < Sinatra::Application

	include Koala

	set :root, APP_ROOT

	enable :sessions, :logging, :show_exceptions

  configure do
    set :protection, :except => [:remote_token, :frame_options]
    set :haml, {:format => :html5}
    set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
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

    def logged_in?
      return session['access_token'] != nil
    end

    def active_user
      return unless logged_in?
      
      graph = Koala::Facebook::API.new(session['access_token'])
      me = graph.get_object('me')
      logger.debug me.inspect
      return me['name']
    end
  end

  before do
    logger.level = Logger::DEBUG
    logger.debug "---------------------------------------------------------"
    logger.debug "---------------------------------------------------------"
    logger.debug "Handling request from host #{request.env['REMOTE_HOST']}"
    logger.debug "Session ID: #{session['session_id']}"
    logger.debug "---------------------------------------------------------"
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
		logger.debug "Set session['oauth'] : #{session['oauth'].inspect}"
    logger.debug "Session id: #{session['session_id']}"
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code()
	end

	get '/logout' do
	  logger.debug "Logout from session #{session['session_id']}"
		session['oauth'] = nil
		session['access_token'] = nil
		redirect '/'
	end

	#method to handle the redirect from facebook back to you
	get '/callback' do
		#get the access token from facebook with your code
		if session['oauth'] == nil
		  logger.error "Could not find oauth key in session #{session['session_id']}"
    else
      session['access_token'] = session['oauth'].get_access_token(params[:code])
		end
		redirect '/'
	end

end
