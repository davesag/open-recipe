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
require 'unicode_utils'
require 'ruby-units'
require 'rabl'
require 'tactful_tokenizer'

# register your app at facebook to get these codes
APP_ID = 435425809841072 # the app's id
APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

# testing at http://ppp167-251-9.static.internode.on.net:5000/
SITE_HOST = 'ppp167-251-9.static.internode.on.net:5000'
SITE_URL = "http://#{SITE_HOST}/" # your app site url

# don't change this without changing the callback route below.
CALLBACK_URL = SITE_URL + 'callback'

#There are 31536000 seconds in a year
LONG_CACHE_LENGTH = 31536000

class OpenRecipeApp < Sinatra::Application
  register Sinatra::R18n
  Rabl.register!
	include Koala

	set :root, APP_ROOT
  set :name, 'Open Recipe'
  set :tagline, 'Food with Friends'
  set :short_name, 'open-recipe'
  set :owner, 'Open Recipe Pty Ltd'
  set :owner_website, SITE_URL
  set :notification_email, 'dave.sag@openrecipe.com.au'
  set :no_reply_email, 'davesag+no_reply@gmail.com'
  set :no_reply_identity, 'Open Recipe Robot'
  set :author, 'Dave Sag'
  set :author_email, 'davesag@gmail.com'
  set :description, 'Open Recipe is a Facebook app for sharing and discovering recipes with your friends.'
  set :keywords, 'recipe, food, eating, drinking, cocktails, meals, restuarants'
  set :root, File.dirname(__FILE__)
  set :models, Proc.new { root && File.join(root, 'models') }
  set :facebook_permissions, ["read_friendlists", "publish_stream","email", "user_likes", "user_photos"]
  set :tokeniser, TactfulTokenizer::Model.new
  
	enable :logging, :show_exceptions
  #enable :sessions # disabled as per http://www.sinatrarb.com/faq.html#sessions
  # rack session set up in config.ru instead.

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

#    require 'simplecov'
#    SimpleCov.start
#    SimpleCov.command_name 'Unit Tests'

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

    def meta_tags (recipe = nil)
      result = [
        {:property => 'og:site_name', :content => "#{settings.name} - #{settings.tagline}."},
        # todo: change this when we can attach an image to a recipe.
        {:property => "og:image", :content => "#{settings.owner_website}images/Open_Recipe_Logo_Square_210x210.png"},
        {:property => "og:url", :content => request.url},
        {:rel => "canonical", :href => request.url},
        {:name => "keywords", :content => settings.keywords},
        {:property => 'fb:app_id', :content => APP_ID}
      ]
      if logged_in?
        result << {:property => 'og:locale', :content => locale_code}
      end
      if recipe == nil
        result << {:property => 'og:type', :content => 'website'}
        result << {:property => "og:title", :content => settings.name}
        result << {:property => 'og:description', :content => settings.description}
        result << {:name => "description", :content => settings.description}
      else
        result << {:property => 'og:type', :content => 'open-recipe:recipe'}
        result << {:property => 'og:title', :content => recipe.name}
        result << {:property => 'open-recipe:owner', :content => recipe.owner.remote_id}
        result << {:property => 'og:description', :content => summarise(recipe.description, 1000)}
        result << {:name => "description", :content => summarise(recipe.description, 250)}
      end
      return result
    end

    # deprecated.  Not needed in latest version of Sinatra
    def rabl(template, options = {}, locals = {})
      # Rabl.register!
      render :rabl, template, options, locals
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

    def locale_code
      return 'en_US' if session[:locale] == nil # facebook's default.
      return session[:locale]
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
      return menu
    end

    def any_tags?
      return true if logged_in? && !active_user.favourite_tags.empty?
      in_use = Tag.in_use.empty?
      return true if !Tag.in_use.empty?
      return true if used_tags.empty? && !Tag.all.empty?
      return false
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

    # summarise the supplied text to less than the supplied charcount.
    # if charcount = 0 then just return the first sentence.
    # else if charcount < text.length then break at a whole word.
    def summarise(text, charcount = 0)
      return text if text.length <= charcount
      sentences = settings.tokeniser.tokenize_text(text)
      return sentences[0] if charcount == 0
      i = 0
      result = ''
      total_length = 0
      # which sentence gets broken by the charcount?
      sentences.each do |sentence|
        total_length = total_length + sentence.length
        if total_length < charcount
          result << sentence
          result << ' '
          i += 1
        else
          break
        end
      end
      return result if i > 0
      #  todo: break at words otherwise
      result = sentence[0]
      return result
    end

    def ingredient_names
      # return Ingredient.find(:all, :select => 'name', :order => 'name collate nocase ASC').to_json
      # note the above returns a hash of objects, not an array of ingredient names.
      # I could have just walked through that result and populated an array, but that seemed slow.
      # see http://patshaughnessy.net/2010/9/4/activerecord-with-large-result-sets-part-1-select_all-vs-find
      # for the following solution.
      return ActiveRecord::Base.connection.select_values('SELECT name FROM ingredients ORDER BY name COLLATE NOCASE ASC').to_json;
    end

    def human_readable_quantity(a_quantity)
      a = a_quantity.amount
      u = a_quantity.unit
      
      pu = ''
      whole = 0
      frac = 0.0
      # look for common fractions
      # like 0.33, 0.5, 0.25, 0.125
      whole = a.to_i unless a == nil
      frac = (a % 1).to_f unless a == nil      
      f = nil
      f = '' if frac == 0.0                           # no fraction.
      f = '&#xbd;' if frac == 0.5                     # 1 half
      f = '&#xbc;' if frac == 0.25                    # 1 quarter
      f = '&#xbe;' if frac == 0.75                    # 3 quarter
      f = '&#x215b;' if frac == 0.125                 # 1 eighth
      f = '&#x215c;' if frac == 0.375                 # 3 eighths
      f = '&#x215d;' if frac == 0.625                 # 5 eighths
      f = '&#x215e;' if frac == 0.875                 # 7 eighths
      f = '&#x2153;' if (frac >= 0.3 && frac < 0.36)  # 1 third
      f = '&#x2154;' if (frac >= 0.65 && frac < 0.7)  # 2 thirds
      f = '&#x2155;' if frac == 0.2                   # 1 fifth
      f = '&#x2156;' if frac == 0.4                   # 2 fifths
      f = '&#x2157;' if frac == 0.6                   # 3 fifths
      f = '&#x2158;' if frac == 0.8                   # 4 fifths
      f = "#{sprintf('%d', frac)}" if f == nil
      if '' == f
        pu = "#{t.n_units[u.name, whole]}" if u!= nil && 0 != whole
        pu = "#{whole}" if u == nil && 0 != whole
      elsif 0 == whole
        pu = "#{f} #{t.units[u.name]}" if u!= nil
        pu = f if u == nil
      else
        pu = "#{whole} #{f} #{t.units[u.name]}" if u != nil
        pu = "#{whole} #{f}" if u == nil
      end
      # logger.debug "pu = #{pu.inspect}"
      return "#{pu}"
    end

    def human_readable_time(seconds)
      return t.ui.none if seconds === 0
      minutes = seconds.divmod(60)[0] # discard seconds.
      hours, minutes = minutes.divmod(60)
      days, hours= hours.divmod(24)
      result = ''
      result << "#{t.n_units.day days} " if days > 0
      result << "#{t.n_units.hour hours} " if hours > 0
      result << "#{t.n_units.minute minutes}" if minutes > 0
      return result
    end

    # return a concise string in 1d 11h 11m format
    def dhhmm_from_seconds(seconds)
      minutes = seconds.divmod(60)[0] # discard seconds.
      hours, minutes = minutes.divmod(60)
      days, hours= hours.divmod(24)
      result = ''
      result << "#{days}d " if days > 0
      result << "#{hours}h " if hours > 0
      result << "#{minutes}m " if minutes > 0
      return result.strip
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

    # move to the Recipe object.
    def parse_ingredients_from_json(recipe_json)
      ais = recipe_json['active_ingredients']
      result = []
      ais.each do |ai|
        logger.debug ai.inspect
        i = ai['ingredient']
        ingredient = Ingredient.where(:name => i).first_or_create
        q = ai['quantity']
        uid = q['unit_id']
        u = AllowedUnit.find_by_id(uid)
        quantity = Quantity.create(:amount => q['amount'], :unit => u)
        result << ActiveIngredient.create(:ingredient => ingredient,
                                                    :quantity => quantity)
      end
      return result
    end

    # move to the Recipe object.
    def parse_recipe_from_json(recipe_json)
      id = recipe_json['id'].to_i
      n = recipe_json['name']
      d = recipe_json['description']
      s = recipe_json['serves'].to_i
      ct = recipe_json['cooking_time'].to_i
      pt = recipe_json['prep_time'].to_i
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

    # todo: expand this with more specific permissions.
    # any logged in user can view any recipe.
    def allowed_to_view?(recipe)
      return logged_in?
    end

    def user_owns?(recipe)
      if logged_in?
        # if the recipe belongs to the user then true
        return true if recipe.owner === active_user
      end
      return false
    end

    # todo: expand this with more specific permissions.
    # only users can edit their own recipes
    def allowed_to_edit?(recipe)
      return user_owns?(recipe)
    end

    def logged_in?
      session['access_token'] = nil if (session['access_token'] != nil && session['access_token'].empty?)
      return session['access_token'] != nil
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
    return if @active_user != nil # active_user is already loaded.
    if !logged_in?
      logger.debug "@active_user is nil and so is session['access_token']"
      return
    end
    @active_user = User.find_by_id(session['user_id']) unless session['user_id'] == nil
    if (@active_user == nil)
      me = graph.get_object('me')
      @active_user = User.where(:username => me['username']).first_or_create(:remote_id => me['id'].to_i)
      @active_user.update_from_facebook me
      @active_user.save
      session['user_id'] = @active_user.id
      logger.debug "Loaded @active_user = #{@active_user.inspect} from Facebook."
    else
      logger.debug "Found @active_user.id = #{@active_user.id} in the database."
      logger.debug "@active_user.name = #{@active_user.name}."
    end
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

  not_found do
    haml :'404'
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
    # logger.debug "session['session_id'] = #{session['session_id']}"
		# redirect to facebook to get your code
		redirect_url = session['oauth'].url_for_oauth_code(:permissions => settings.facebook_permissions)
		# logger.debug "redirecting to '#{redirect_url}'"
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
    if logged_in?
      haml :browse
    else
      status 403
      haml :'403'
    end
  end

  get '/settings' do
    if logged_in?
      haml :settings
    else
      status 403
      haml :'403'
    end
  end

  get '/faqs' do
    haml :faqs
  end

  get '/fb_channel' do
    response['Pragma'] = "public"
    response['Cache-Control'] = "max-age=#{LONG_CACHE_LENGTH}"
    response['Expires'] = (Time.new + LONG_CACHE_LENGTH).utc.strftime("%a, %d %b %Y %H:%M:%S %Z") # eg Thu, 01 Dec 1994 16:00:00 UTC
    # as per https://developers.facebook.com/docs/reference/javascript/
    # adding a channel file.
    "<script src='//connect.facebook.net/#{locale_code}/all.js'></script>"
  end

  get '/fbt' do
    haml :fb_status_test
  end

  get '*.html\??*' do
    #only use while testing.
    filename = "#{params[:splat][0]}.html"
    file = File.join(settings.public_folder, filename)
    if File.exists? file
      File.read file
    else
      status 404
      haml :'404'
    end
  end
  
  # search request comes from jQuery UI component.
  # user must be logged in for this to return a sensible result.
  get '/search' do
    if request.xhr? && logged_in?
      content_type :json
      term = params[:term]
      logger.debug "Got search request #{params[:term]}."
    
      # find tags, ingredients, recipes, meals.
      result = []
      Tag.name_contains(term).each do |tag|
        result << {:value => tag.id, :label => "Tag: #{tag.name}"}
      end
      return result.to_json
    else
      status 403
      haml :'403'
    end
  end

  get '/favourite-tags' do
    if request.xhr? && logged_in?
      content_type :json
      if !active_user.favourite_tags.empty?
        rabl :favourite_tags, :locals => {:tags => active_user.favourite_tags.sort_by(&:name)}
      else
        used_tags = Tag.in_use  # returns sorted list by default.
        used_tags = Tag.find(:all, :order => 'name collate nocase ASC') if used_tags.empty?
        rabl :favourite_tags, :locals => {:tags => used_tags}        
      end
    else
      status 403
      haml :'403'
    end
  end

  # return an array of the active user's own recipes,
  # with 'active_ingredient" details.
  # todo: forcing AJAX is off while I test this.
  get '/recipes/with_ingredients' do
    if request.xhr? && logged_in?
      content_type :json
      return active_user.recipes.to_json(:include => :active_ingredients)   
    else
      status 403
      haml :'403'
    end
  end
  
  # return an array of the active user's own recipes in summary form,
  # localised and formatted for use by a dataTable object.
  # see http://datatables.net/usage/server-side and also
  # see http://www.datatables.net/release-datatables/examples/server_side/ids.html
  get '/recipes/datatable\??*' do
    if request.xhr? && logged_in?
      content_type :json
      rabl :recipes_datatable, :locals => { :recipes => active_user.recipes,
                                            :echo => params[:sEcho].to_i,
                                            :table_name => params['tName'] }
    else
      status 403
      haml :'403'
    end
  end

  # return an array of the active user's own recipes in summary form,
  # localised and formatted for use by a dataTable object.
  # see http://datatables.net/usage/server-side and also
  # see http://www.datatables.net/release-datatables/examples/server_side/ids.html
  get '/favourite-recipes/datatable\??*' do
    if request.xhr? && logged_in?
      rabl :recipes_datatable, :locals => { :recipes => active_user.favourite_recipes,
                                            :echo => params[:sEcho].to_i,
                                            :table_name => params['tName'] }
    else
      status 403
      haml :'403'
    end
  end

  # return an array of all of the recipes in summary form,
  # localised and formatted for use by a dataTable object.
  # see http://datatables.net/usage/server-side and also
  # see http://www.datatables.net/release-datatables/examples/server_side/ids.html
  # todo: only dish up the bits of the recipe needed to display
  #       to improve performance when the list gets long.
  get '/all-recipes/datatable\??*' do
    if request.xhr?
      rabl :all_recipes_datatable, :locals => { :recipes => Recipe.all,
                                            :echo => params[:sEcho].to_i,
                                            :table_name => params['tName'] }
    else
      status 403
      haml :'403'
    end
  end

  # return an array of the active user's own recipes in raw summary form.
  # todo: forcing AJAX is off while I test this.
  get '/recipes' do
    if request.xhr? && logged_in?
      content_type :json
      return active_user.recipes.to_json(:include => :active_ingredients)   
    else
      status 403
      haml :'403'
    end
  end

  get '/create-recipe' do
    if logged_in?
      haml :recipe_create_or_edit
    else
      status 403
      haml :'403'
    end
  end

  get '/recipe/:id' do
    recipe = Recipe.find_by_id(params[:id].to_i)
    if request.xhr?
    	content_type :json
      # handle as AJAX
      if !logged_in?
        status 403
        return {:success => false, :error => 'unauthorised_access'}.to_json
      end
      if recipe == nil
        status 404
        return {:success => false, :error => 'recipe_not_found'}.to_json
      end
      rabl :recipe, :locals => {:recipe => recipe}
    else
      if recipe != nil
        haml :recipe_display, :locals => {:recipe => recipe} 
	    else
  	    status 404
	      haml :'404'
      end
    end
  end

  get '/edit-recipe/:id' do
    if logged_in?
      recipe = Recipe.find_by_id(params[:id].to_i)
      if recipe != nil
        haml :recipe_create_or_edit, :locals => {:recipe => recipe}
      else
        status 404
        haml :'404'
      end
    else
      status 403
      haml :'403'
    end
  end

  post '/favourite-recipe/:id' do
    if logged_in? && request.xhr?
      recipe = Recipe.find_by_id(params[:id].to_i)
      if recipe != nil
        #todo: add it as a favourite.
        return {:success => true, :message => 'recipe_favourited'}.to_json
      else
        status 404
        return {:success => false, :error => 'recipe_not_found'}.to_json
      end
    else
      status 403
      haml :'403'
    end
  end

  # receive a recipe create or update request via JSON.
  post "/recipe-request" do
    if request.xhr?
      content_type :json
      logger.debug 'Login Request Received.'
      return {:success => false, :error => 'unauthorised_access'}.to_json unless logged_in?

      req = JSON.parse request.body.read
      parse_recipe_from_json req['recipe']
      logger.debug "Recieved Recipe Request: #{req.inspect}"

      return {:success => true, :message => 'Recipe Saved.'}.to_json
    else
      status 403
      haml :'403'
    end
  end

end
