# Populate this model via seeding at startup.
require 'active_record'

class FavouriteRecipe < ActiveRecord::Base

  belongs_to :recipe
  belongs_to :user
  # Integer :rating

end
