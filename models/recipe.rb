# Populate this model via user facing web-ui.
require 'active_record'

class Recipe < ActiveRecord::Base

  validates_presence_of :name
  # validates_uniqueness_of :slug
  validates_presence_of :serves
  
  # todo: make this cleaner.
  # before_save :tweak_slug
  
  # :cooking_time, Integer # seconds.
  # :preparation_time, Integer # seconds.
  # :description, Text
  # :method, Text
  # :requirements, Text

  has_and_belongs_to_many :ingredients  # ingredients made according to this recipe.
  has_and_belongs_to_many :users # users have favourite recipes.
  has_many :active_ingredients, :dependent => :destroy  # ingredients used to make this recipe with, 
                                        # in addition to their quantities.
  has_and_belongs_to_many :tags # tags for this recipe.
  has_and_belongs_to_many :photos # photos of this recipe.
  
  belongs_to :owner, :class_name => 'User'
  belongs_to :meal
  
  # see http://stackoverflow.com/questions/1302022/best-way-to-generate-slugs-human-readable-ids-in-rails
#   def to_slug
#     #strip the string
#     ret = self.name.strip
# 
#     #blow away apostrophes
#     ret.gsub! /['`]/,""
# 
#     # @ --> at, and & --> and
#     ret.gsub! /\s*@\s*/, " at "
#     ret.gsub! /\s*&\s*/, " and "
# 
#     #replace all non alphanumeric, underscore or periods with underscore
#      ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  
# 
#      #convert double underscores to single
#      ret.gsub! /_+/,"_"
# 
#      #strip off leading/trailing underscore
#      ret.gsub! /\A[_\.]+|[_\.]+\z/,""
# 
#      ret
#   end
  
end
