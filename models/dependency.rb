# Unit Type Model
# Populate this model via seeding at startup, and then maintain via an admin interface.
require 'data_mapper'

class Dependency
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 1..75
  belongs_to :dependency_type, :required => true
  belongs_to :source_requirement, 'Requirement', :key => true
  belongs_to :target_requirement, 'Requirement', :key => true
end
