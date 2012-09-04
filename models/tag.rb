# Populate this model via seeding at startup, and then maintain via user-facing web-ui.

require 'active_record'

class Tag < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :users #users who have this as a favourite tag.
  has_and_belongs_to_many :meals # meals tagged with this tag.
  has_and_belongs_to_many :ingredients # ingredients tagged with this tag.
  has_and_belongs_to_many :recipes # recipes tagged with this tag.

  scope :name_starts_with, lambda { |str|
    {:conditions => ["name like ?", "#{str.downcase}%"]}
  }
  
  # it's in_use if users.count >0 || meals.count > 0 || … etc
  def self.in_use
    return Tag.find_by_sql('select tags.* from tags
      inner join tags_users on tags.id = tags_users.tag_id
      inner join users on tags_users.user_id = users.id
      union
      select tags.* from tags
      inner join meals_tags on tags.id = meals_tags.tag_id
      inner join meals on meals_tags.meal_id = meals.id
      union
      select tags.* from tags
      inner join ingredients_tags on tags.id = ingredients_tags.tag_id
      inner join ingredients on ingredients_tags.ingredient_id = ingredients.id
      union
      select tags.* from tags
      inner join recipes_tags on tags.id = recipes_tags.tag_id
      inner join recipes on recipes_tags.recipe_id = recipes.id')
  end
end
