# Populate this model via seeding at startup, and then maintain via user facing web-ui.

require 'active_record'

class Meal < ActiveRecord::Base

  validates_uniqueness_of :name
  # :description, Text
  belongs_to :meal_type
  has_many :recipes
  has_and_belongs_to_many :tags

end
