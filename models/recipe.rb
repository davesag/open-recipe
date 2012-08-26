# Populate this model via user facing web-ui.
require 'active_record'

class Recipe < ActiveRecord::Base

  validates_uniqueness_of :name
  # :cooking_time, Integer
  # :preparation_time, Integer
  # :description, Text
  # :method, Text
  # :requirements, Text

  has_and_belongs_to_many :ingredients  # recipes to make this ingredient.
  has_and_belongs_to_many :active_ingredients  # ingredients to make this recipe with quantities
  has_and_belongs_to_many :tags
  belongs_to :owner, :class_name => 'User'
  belongs_to :meal
  has_many :favourite_recipes
  
end
