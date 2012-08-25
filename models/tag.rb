# Tag Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..75, :unique => true
  has n,   :users, :through => Resource
#   has n, :meals, :through => Resource
#   has n, :ingredients, :through => Resource
#   has n, :recipes, :through => Resource
end
