# Populate this model via user facing web-ui.

require 'active_record'

class Ingredient < ActiveRecord::Base

  validates_uniqueness_of :name
  # :description, String, :length => 1..255
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :recipes #These are the recipes to make this ingredient.
  has_and_belongs_to_many :recipes_using,
                            :class_name => 'Recipe',
                            :join_table => 'ingredients_recipes_using' # recipes this ingredient goes into.
end
