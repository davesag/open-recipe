# Unit Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class Ingredient
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..75
  property :summary, String, :length => 1..255
#   has n, :tags, :through => Resource
#   has n, :recipes, :through => Resource
end
