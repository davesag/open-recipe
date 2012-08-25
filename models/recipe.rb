# Unit Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class Recipe
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..255
  property :cooking_time, Integer
  property :description, Text
  property :method, Text
#   has 1, :user, :via => :owner
#   has 1, :meal
#   has n, :tags, :through => Resource
#   has n, :recipes, :through => Resource
#   has n, :requirements, :through => Resource
#   has n, :ingredients, :through => Resource
end
