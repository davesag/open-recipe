# Populate this model via Facebok.
require 'active_record'

class Location < ActiveRecord::Base

  validates_presence_of :name
  # :latitude, Decimal
  # :longitude, Decimal
  belongs_to :location_type
  has_many :retailers
  has_many :restaurants
  
end
