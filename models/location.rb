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

  def update_from_facebook(me)
    n = me['name']
    if n == nil || n.empty?
      puts "Could not access location name from data returned by Facebook." 
      return false
    end
    puts "Loaded Facebook location #{n}."
    
    self.name = n
    self.latitude = me['location']['latitude'].to_f
    self.longitude = me['location']['longitude'].to_f
    self.remote_id = me['id'].to_i
    category = me['category']
    self.location_type = LocationType.where(:name => category).first_or_create
    return true
  end

end
