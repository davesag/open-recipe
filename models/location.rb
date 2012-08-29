# Populate this model via Facebok.
require 'active_record'

class Location < ActiveRecord::Base

  validates_presence_of :name
  # :latitude, Decimal
  # :longitude, Decimal
  validates_uniqueness_of :remote_id
  belongs_to :location_type
  has_many :retailers
  has_many :restaurants
  has_many :users, :foreign_key => :current_location_id

end
