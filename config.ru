require './open_recipe_app'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
use Rack::Session::Cookie,  :key => 'open.recipe.session',
                            :path => '/',
                            :expire_after => 2592000, #30 days
                            :secret => 'shh_replace_me_ors'

run OpenRecipeApp

