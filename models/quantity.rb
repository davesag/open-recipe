# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Quantity < ActiveRecord::Base

  # Decimal :amount
  belongs_to :unit, :class_name => "AllowedUnit" # the unit of this quantity.
end
