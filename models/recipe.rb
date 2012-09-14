# Populate this model via user facing web-ui.
require 'active_record'

class Recipe < ActiveRecord::Base

  validates_presence_of :name
  # :cooking_time, Integer # seconds.
  # :preparation_time, Integer # seconds.
  # :description, Text
  # :method, Text
  # :requirements, Text

  has_and_belongs_to_many :ingredients  # ingredients made according to this recipe.
  has_many :active_ingredients, :dependent => :destroy  # ingredients used to make this recipe with, 
                                        # in addition to their quantities.
  has_and_belongs_to_many :tags # tags for this recipe.
  has_and_belongs_to_many :photos # photos of this recipe.
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :meal
  has_many :favourite_recipes # recipes with a rating.
  
end
