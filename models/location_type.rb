# Populate this model via user facing web-ui.
require 'active_record'

class LocationType < ActiveRecord::Base

  validates_uniqueness_of :name
  # :effective_gps_radius, Integer # metres
  has_many :locations
  
end
