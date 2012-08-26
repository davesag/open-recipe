# Populate this model via seeding at startup.
require 'active_record'

class UnitType < ActiveRecord::Base

  validates_uniqueness_of :name
  has_many :allowed_units

end
