# Populate this model via Facebook, and allow user to maintain via UI

require 'active_record'

class Photo < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :ingredients
  has_and_belongs_to_many :restaurants
  has_and_belongs_to_many :recipes
  has_and_belongs_to_many :retailers

end
