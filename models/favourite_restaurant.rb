# Populate this model via seeding at startup, and allow user to maintain via UI
require 'active_record'

class FavouriteRestaurant < ActiveRecord::Base

  belongs_to :restaurant
  belongs_to :user
  # Integer :rating

end
