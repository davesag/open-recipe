# Populate this model with data from Facebook.

require 'active_record'

class User < ActiveRecord::Base

  validates_uniqueness_of :username
  # :name, String, :length => 1..75
  # :sex, String, :length => 1..7
  # :first_name, String, :length => 1..25
  # :last_name, String, :length => 1..25
  # :email, String, :length => 1..75
  # :remote_id, Integer, :unique => true
  # :profile_picture_url, String, :length => 1..255
  # :locale, String, :length => 1..6

  has_and_belongs_to_many :favourite_tags, :class_name => 'Tag'
  has_many :recipes, :foreign_key => :owner_id, :dependent => :destroy
  has_many :favourite_recipes, :dependent => :destroy
  has_many :photos, :foreign_key => :owner_id, :dependent => :destroy
  has_many :preferences, :dependent => :destroy

  def update_from_facebook(me)
    n = me['name']
    if n == nil || n.empty?
      puts "Could not access name from credentials returned by Facebook." 
      return false
    end
    puts "Loaded Facebook user #{n}."
    if 'true' != me['verified'].to_s
      puts "But alas Facebook user #{n} is unverified by Facebook."
      puts "verified = '#{me['verified']}'"
      return false
    end
    
    self.name = n
    self.first_name = me['first_name']
    self.last_name = me['last_name']
    self.username = me['username']
    self.email = me['email']
    self.sex = me['gender']
    self.remote_id = me['id'].to_i
    self.profile_picture_url = "https://graph.facebook.com/#{me['id']}/picture&type=square"
    self.locale = me['locale']
    return true
  end

end
