#!usr/bin/ruby

require './open_recipe_app'
require 'test/unit'
require 'rack/test'
require 'date'

class HandlerTestBase < Test::Unit::TestCase
  include Rack::Test::Methods

# pull the app definition from the Rack config file.
  def app
    @app ||= Rack::Builder.parse_file(File.join(OpenRecipeApp.root,"config.ru"))[0]
  end

  # just a dummy test that is needed for some reason
  def test_nothing
    return true
  end

end
