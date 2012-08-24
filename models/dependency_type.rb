# Unit Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class DependencyType
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..25
  property :is_symmetric, Boolean
  property :forward_text, String, :length => 1..225
  property :reverse_text, String, :length => 1..225

  has n, :dependencies
end
