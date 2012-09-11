# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Preparation < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :active_ingredients

end
