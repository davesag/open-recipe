# Populate this model via seeding at startup, and allow user to maintain via UI
require 'active_record'

class FavouriteRetailer < ActiveRecord::Base

  belongs_to :retailer
  belongs_to :user
  # Integer :rating

end
