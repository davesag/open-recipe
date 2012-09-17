#!/user/bin/env ruby
#coding: utf-8

APP_ROOT = File.dirname(__FILE__)

require 'sinatra/base'
require 'sinatra/r18n'
require 'haml'
require 'koala'
require 'logger'
require 'active_record'
require 'active_support/all'  # added for Time.zone support below
require 'unicode'
require 'ruby-units'

# register your app at facebook to get these codes
APP_ID = 435425809841072 # the app's id
APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

# testing at http://ppp167-251-9.static.internode.on.net:5000/
# production tests at http://open-recipe.herokuapp.com
SITE_URL = 'http://ppp167-251-9.static.internode.on.net:5000/' # your app site url

# don't change this without changing the callback route below.
CALLBACK_URL = SITE_URL + 'callback'

class OpenRecipeApp < Sinatra::Application
  register Sinatra::R18n
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
  set :facebook_permissions, ["read_friendlists", "publish_stream","email", "user_likes", "user_photos"]

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
  # @todo: On Heroku you need to set the TZ environment variable. You won't want to keep using the default time zones
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
    ActiveRecord::Base.logger.level = Logger::ERROR      #not interested in database stuff right now.

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

    def summarise_tag (tag, zero_okay = true)
      rc = tag.recipes.count
      mc = tag.meals.count
      ic = tag.ingredients.count
      tot = rc + mc + ic
      
      return {:name => tag.name, :count => tot, :counts => {:recipes => rc,
                                                          :meals => mc,
                                                          :ingredients => ic}}
    end

    def popular_tags
      tags = []
      if logged_in? && !active_user.favourite_tags.empty?
        active_user.favourite_tags.sort_by(&:name).each do |tag|
          ts = summarise_tag(tag)
          tags << ts unless ts == nil
        end
      else
        used_tags = Tag.in_use  # returns sorted list by default.
        used_tags = Tag.find(:all, :order => 'name collate nocase ASC') if used_tags.empty?
        used_tags.each do |tag|
          ts = summarise_tag(tag)
          tags << ts unless ts == nil
        end
      end
      return tags
    end

    def allowed_units
      result = [{:kind => 'option', :value => '', :label => Unicode::capitalize(t.units.none)}]
      UnitType.all.each do |ut|
        result << {:kind => 'optgroup', :label => Unicode::capitalize(ut.name)}
        ut.allowed_units.order(:name).each do |u|
          result << {:kind => 'option', :value => u.id,
                     :label => Unicode::capitalize(t.units[Unit(u.name).unit_name])}
        end
      end
      return result.to_json
    end

    def preparations
      result = [{:kind => 'option', :value => '', :label => Unicode::capitalize(t.units.none)}]
      Preparation.all.each do |p|
        result << {:kind => 'option', :value => p.id,
                   :label => Unicode::capitalize(t.preparation[p.name])}
      end
      return result.to_json
    end

    def ingredient_names
      # return Ingredient.find(:all, :select => 'name', :order => 'name collate nocase ASC').to_json
      # note the above returns a hash of objects, not an array of ingredient names.
      # I could have just walked through that result and populated an array, but that seemed slow.
      # see http://patshaughnessy.net/2010/9/4/activerecord-with-large-result-sets-part-1-select_all-vs-find
      # for the following solution.
      return ActiveRecord::Base.connection.select_values('SELECT name FROM ingredients ORDER BY name COLLATE NOCASE ASC').to_json;
    end

    def parse_time(a_time)
      # comes in as 'dd:hh:mm'
      times = a_time.split(':')
      return times[0].to_i * 24 * 60 * 60 + 60 * 60 * times[1].to_i + 60 * times[2].to_i
    end

    def parse_tags_from_json(recipe_json)
      tags = recipe_json['tags']
      result = []
      return result if tags == nil
      tags.each do |tag|
        result << Tag.where(:name => tag).first_or_create
      end
      return result;
    end

    def parse_ingredients_from_json(recipe_json)
      ais = recipe_json['active_ingredients']
      result = []
      ais.each do |ai|
        i = ai['ingredient']
        ingredient = Ingredient.where(:name => i).first_or_create
        pid = ai['preparation_id']
        uid = ai['unit_id']
        q = ai['quantity']
        quantity = Quantity.create(:amount => q['amount'],
                                    :unit => AllowedUnit.find_by_id(uid))
        preparation = Preparation.find_by_id(pid)
        result << ActiveIngredient.create(:ingredient => ingredient,
                                                    :quantity => quantity,
                                                    :preparation => preparation)
      end
      return result
    end

    def parse_recipe_from_json(recipe_json)
      id = recipe_json['id'].to_i
      n = recipe_json['name']
      d = recipe_json['description']
      s = recipe_json['serves'].to_i
      ct = parse_time recipe_json['cooking_time']
      pt = parse_time recipe_json['prep_time']
      m = recipe_json['method']
      r = recipe_json['requirements']
      mn = recipe_json['meal']
      ActiveRecord::Base.transaction do |t|
        active_ingredients = parse_ingredients_from_json recipe_json
        tags = parse_tags_from_json recipe_json
        meal = nil if mn == nil
        meal = Meal.find_by_name(mn).first_or_create if mn != nil
    
        if id == 0
          recipe = Recipe.create(:owner => active_user, :name => n, :cooking_time => ct,
                                 :preparation_time => pt, :serves => s, :description => d,
                                 :method => m, :active_ingredients => active_ingredients,
                                 :requirements => r, :tags => tags, :meal => meal)
            
        else  # a non-zero id implies we are saving an existing record.
          recipe = Recipe.find_by_id(id)
          recipe.owner = active_user unless recipe.owner.id == active_user.id
          recipe.name = n unless recipe.name == n
          recipe.cooking_time = ct unless recipe.cooking_time == ct
          recipe.preparation_time = pt unless recipe.preparation_time == pt
          recipe.description = d unless recipe.description == d
          recipe.method = m unless recipe.method == m
          recipe.requirements = r unless recipe.requirements == r
          recipe.serves = s unless recipe.serves == s
          
          logger.debug "Todo: save active ingredients, tags and meal"
          # active ingredients
          # first go through and remove any ingredients we currently have
          recipe.active_ingredients.each {|ai| ai.destroy}
          recipe.active_ingredients = active_ingredients
          # tags
          recipe.tags = tags
          
          # meal
          recipe.meal = meal
          recipe.save
        end
      end
    end

    def logged_in?
      logger.debug "logged_in?"
      if session['access_token'] != nil && session['access_token'].empty?
        logger.debug "session['access_token'] is non-nil but empty, so reset it to nil"
        session['access_token'] = nil
      end
      if session['access_token'] == nil
        logger.debug "Not Logged In."
        return false
      end
      logger.debug "Logged In with access token #{session['access_token']}."
      return true
    end

    def active_user
      return nil unless logged_in?
      load_active_user
      return @active_user
    end
    
    def graph
      if @graph == nil
        logger.debug "Loading Facebook Graph using access token '#{session['access_token']}'"
        @graph = Koala::Facebook::API.new(session['access_token'])
      end
      return @graph
    end
    
    def logout_user!
      logger.debug "Logout from session #{session['session_id']}"
      session['oauth'] = nil
      session['access_token'] = nil
      session['user_id'] = nil
      @active_user = nil
      @graph = nil
    end
  end

  def load_active_user
    logger.debug "Loading active User into @active_user"
    return if @active_user != nil # active_user is already loaded.
    if !logged_in?
      logger.debug "@active_user is nil and so is session['access_token']"
      return nil
    end
    if session['user_id'] == nil
      logger.debug "There is no saved user_id in this session."
    else
      logger.debug "session['user_id'] = #{session['user_id']}"
      logger.debug "Looking in the database for a user with id #{session['user_id']}"
      @active_user = User.find_by_id(session['user_id'])
    end
    if (@active_user == nil)
      logger.debug "There was no user with id = #{session['user_id']}"
      me = graph.get_object('me')
      logger.debug "me = #{me.inspect}"
      @active_user = User.where(:username => me['username']).first_or_create(:remote_id => me['id'].to_i)
      logger.debug "@active_user = #{@active_user.inspect}"
      @active_user.update_from_facebook me
      logger.debug "@active_user = #{@active_user.inspect}"      
      @active_user.save
      session['user_id'] = @active_user.id
      logger.debug "session['user_id'] = #{session['user_id']}"
    else
      logger.debug "Found @active_user.id = #{@active_user.id} in the database."
    end
    return @active_user
  end

  before do
    logger.level = Logger::DEBUG
    logger.debug "========================================================="
    logger.debug "---------------------------------------------------------"
    logger.debug "Handling request from host #{request.env['REMOTE_HOST']}"
    logger.debug "Session ID: #{session['session_id']}"
    logger.debug "---------------------------------------------------------"

    session[:locale] = params[:locale] if params[:locale] #the r18n system will load it automatically
    load_active_user
    session[:locale] = @active_user.locale if @active_user != nil && session[:locale] == nil
    logger.debug "session[:locale] = '#{session[:locale]}'"
  end

  after do
    logger.debug "---------------------------------------------------------"
    logger.debug "Session ID: #{session['session_id']}"
    logger.debug "Completed request from host #{request.env['REMOTE_HOST']}"
    logger.debug "---------------------------------------------------------"
    logger.debug "========================================================="
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
		logger.debug "Received login request."
		session['oauth'] = Facebook::OAuth.new(APP_ID, APP_CODE, CALLBACK_URL)
		logger.debug "session['oauth'] = #{session['oauth'].inspect}"
    logger.debug "session['session_id'] = #{session['session_id']}"
		# redirect to facebook to get your code
		redirect_url = session['oauth'].url_for_oauth_code(:permissions => settings.facebook_permissions)
		logger.debug "redirecting to '#{redirect_url}'"
		redirect redirect_url
	end

	get '/logout' do
		logger.debug "Received logout request."
    logout_user!
		logger.debug "redirecting to '/'"
		redirect '/'
	end

	#method to handle the redirect from facebook back to you
	get '/callback' do
    logger.debug "Received facebook /callback request with params #{params.inspect}"
	  if params[:error] != nil
	    logger.error "Callback received error code: #{params[:error]}"
	    logger.error "Reason: #{params[:error_reason]}"
	    logger.error "Description: #{params[:error_description]}"
	    error = {'name' => params[:error],
	             'description' => params[:error_description],
	             'reason' => params[:error_reason]}
	    haml :error, :locals => {:error => error}
	  else
      #get the access token from facebook with your code
      if session['oauth'] == nil
        logger.error "Could not find oauth key in session #{session['session_id']}"
      else
        logger.debug "Found session['oauth'] = #{session['oauth'].inspect}"
        logger.debug "Using params[:code] = '#{params[:code]}'"
        session['access_token'] = session['oauth'].get_access_token(params[:code])
        logger.debug "session['access_token'] = #{session['access_token']}"
        load_active_user
      end
      logger.debug "redirecting to '/'"
      redirect '/'
    end
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
    haml :faqs
  end

  # search request comes from jQuery UI component.
  # user must be logged in for this to return a sensible result.
  get '/search' do
    return [].to_json unless logged_in?
    term = params[:term]
    logger.debug "Got search request #{params[:term]}."
    
    # find tags, ingredients, recipes, meals.
    result = []
    Tag.name_contains(term).each do |tag|
      result << {:value => tag.id, :label => "Tag: #{tag.name}"}
    end
    return result.to_json
  end

  # receive a recipe create or update request via JSON.
  post "/recipe-request" do
  	content_type :json
  	logger.debug 'Login Request Received.'
    req = JSON.parse request.body.read
    parse_recipe_from_json req['recipe']
    # logger.debug "Recieved Recipe Request: #{req.inspect}"

    return {:success => true, :message => 'Recipe Saved.'}.to_json
  end

end
