# Populate this model via user facing web-ui.

require 'active_record'

class CoreIngredient < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  # :description, String, :length => 1..255
  # :energy, Integer - J per 100g
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :photos #These are photos of this ingredient.
  has_and_belongs_to_many :seasons
  has_and_belongs_to_many :ingredients

  # find the matching core ingredient, if any
  # for the given name.
  def self.match_core(a_name)
    return self.find_by_name(a_name)
  end

end
