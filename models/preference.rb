# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Preference < ActiveRecord::Base

  belongs_to :user
  validates_uniqueness_of :name, :scope => :user_id

end
