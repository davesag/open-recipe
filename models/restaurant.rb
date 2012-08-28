# Populate this model via seeding at startup, and then maintain via user facing web-ui.

require 'active_record'

class Restaurant < ActiveRecord::Base

  validates_presence_of :name
  # :description, Text
  # :remote_id, Integer
  belongs_to :location
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :meals
  has_and_belongs_to_many :recipes
  has_and_belongs_to_many :photos

end
