# Meal Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class MealType
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..75, :unique => true
end
