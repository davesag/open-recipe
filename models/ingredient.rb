# Populate this model via user facing web-ui.

require 'active_record'

class Ingredient < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  # :description, String, :length => 1..255
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :photos #These are photos of this ingredient.
  has_and_belongs_to_many :recipes #These are the recipes to make this ingredient.
  has_and_belongs_to_many :core_ingredients #These are the core ingredients that reference this ingredient.
  has_many :active_ingredients #Ingredients paired with Quantities in specific recipes.

  before_create :import_from_core
  before_update :import_from_core

  # look at the name of this ingredient and try and work out which CoreIngredients match.
  def match_core
  puts "debug: Matching Core Ingredients. self = #{self.inspect}"
    results = []
    result = CoreIngredient.match_core(self.name) # try the whole name first.
    results << result unless (results.include?(result) || result == nil)
    names = self.name.split(' ')                  # then look for individual words
    names.each do |n|
      result = CoreIngredient.match_core(n)
      results << result unless (result == nil || results.include?(result))
    end
    puts "returning results = #{results.inspect}"
    # could get fancy and look for combinations of word pairs too.
    return results
  end

  def import_from_core
    if self.core_ingredients == nil || self.core_ingredients.empty?
      self.core_ingredients = self.match_core
      puts "self.core_ingredients = #{self.core_ingredients.inspect}" if self.core_ingredients != nil
      puts "self.core_ingredients is nil" if self.core_ingredients == nil

      if (self.core_ingredients == nil || self.core_ingredients.empty?)
        puts "self.core_ingredients nill or empty so stop imorting."
        return
      end
    end
    # if there are core_ingredients then import tag data.
    puts "Importing tag data from #{self.core_ingredients.inspect}"
    self.core_ingredients.each do |ci|
      if self.tags == nil || self.tags.empty?
        puts "debug: Importing tags from #{ci.tags.inspect}"
        self.tags = ci.tags
      else
        puts "debug: Merging the tags from #{self.tags.inspect} and #{ci.tags.inspect}"
        self.tags = (self.tags + ci.tags).uniq
      end
    end
  end

  def import_from_core!
    self.import_from_core
    self.save
  end
end
