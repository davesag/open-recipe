# Unit Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class Meal
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..75, :unique => true
  property :description, Text
  belongs_to :meal_type, :required => true
  has n, :tags, :through => Resource
end
