# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Tag < ActiveRecord::Base

  validates_uniqueness_of :name

  has_and_belongs_to_many :users #users who have this as a favourite tag.
  has_and_belongs_to_many :meals # meals tagged with this tag.
  has_and_belongs_to_many :ingredients # ingredients tagged with this tag.
  has_and_belongs_to_many :recipes # recipes tagged with this tag.
end
