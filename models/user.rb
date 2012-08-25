# User Model
# Populate this model with data from Facebook.
require 'data_mapper'

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :length => 1..25, :unique => true
  property :name, String, :length => 1..75
  property :sex, String, :length => 1..7
  property :first_name, String, :length => 1..25
  property :last_name, String, :length => 1..25
  property :email, String, :length => 1..75
  property :remote_id, Integer, :unique => true
  property :profile_picture_url, String, :length => 1..255
  property :locale, String, :length => 1..6

  has n, :tags
  has n, :favourite_tags, :model => 'Tag', :through => Resource
#  has n, :recipes, :through => Resource, :required => false
  
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
