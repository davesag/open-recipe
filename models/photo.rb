# Populate this model via Facebook, and allow user to maintain via UI

require 'active_record'

class Photo < ActiveRecord::Base

  # t.string   :caption
  # t.text     :description

  validates_uniqueness_of :remote_id
  validates_presence_of :name
  validates_presence_of :image_url
  validates_presence_of :thumbnail_url

  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :core_ingredients
  has_and_belongs_to_many :ingredients
  has_and_belongs_to_many :recipes

end
