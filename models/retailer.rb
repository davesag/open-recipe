# Populate this model via seeding at startup, and then maintain via user facing web-ui.

require 'active_record'

class Retailer < ActiveRecord::Base

  validates_presence_of :name
  # :description, Text
  # :remote_id, Integer
  belongs_to :location
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :ingredients  #ingredients stocked by this retailer
  has_and_belongs_to_many :photos

end
