# Populate this model via user facing web-ui.

require 'active_record'

class Ingredient < ActiveRecord::Base

  validates_uniqueness_of :name
  # :description, String, :length => 1..255
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :retailers #These are the retailers of this ingredient.
  has_and_belongs_to_many :photos #These are photos of this ingredient.
  has_and_belongs_to_many :recipes #These are the recipes to make this ingredient.
  has_many :active_ingredients #Ingredients paired with Quantities in specific recipes.
end
