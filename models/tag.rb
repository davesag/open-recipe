# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Tag < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :users #users who have this as a favourite tag.
  has_and_belongs_to_many :meals # meals tagged with this tag.
  has_and_belongs_to_many :ingredients # ingredients tagged with this tag.
  has_and_belongs_to_many :recipes # recipes tagged with this tag.
  has_and_belongs_to_many :restaurants # restaurants tagged with this tag.
  has_and_belongs_to_many :retailers # retailers tagged with this tag.

  scope :name_starts_with, lambda { |str|
    {:conditions => ["name like ?", "#{str.downcase}%"]}
  }
  
  # it's in_use if users.count >0 || meals.count > 0 || … etc
  scope :in_use, lambda { |str|
    {:conditions => ["users.count > 0 OR meals.count > 0 OR ingredients.count > 0 OR recipes.count > 0 OR restaurants.count > 0 OR retailers.count > 0"]}
  }

end
