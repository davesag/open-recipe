# Populate this model via seeding at startup.

require 'active_record'

class Season < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  has_and_belongs_to_many :core_ingredients

end
