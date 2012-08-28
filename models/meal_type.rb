# Populate this model via seeding at startup.

require 'active_record'

class MealType < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :meals

end
