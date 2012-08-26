# Populate this model via seeding at startup.

require 'active_record'

class AllowedUnit < ActiveRecord::Base

  validates_uniqueness_of :name
  belongs_to :unit_type
  has_many :quantities
end
