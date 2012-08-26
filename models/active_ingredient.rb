# Populate this model via user facing web-ui.

require 'active_record'

class ActiveIngredient < ActiveRecord::Base

  belongs_to :recipe  # the recipe being made with this ingredient
  belongs_to :ingredient  # the ingredient to use
  belongs_to :quantity # the amount and units used
end
