require 'test/unit'
require 'rack/test'
require './test/handler_test_base'

class UserTest < HandlerTestBase

  #test creation of Users and related objects.
  def test_create_user

    ActiveRecord::Base.transaction do |t|
      # create a tag
      lunch = Tag.create(:name => 'not quite lunch')
      assert lunch != nil, "Expected lunch to be non nil."
      lunch.reload
      
      # now check - is the Tag saved to the database?
      loaded_lunch = Tag.where(:name => 'not quite lunch').first
      assert loaded_lunch != nil, "Expected loaded_lunch to be non nil."
      assert loaded_lunch.id == lunch.id, "The loaded lunch (id=#{loaded_lunch.id}) was not the same as the created lunch (id=#{lunch.id}.)"
   
      # create a User
      user = User.create(:username => 'bob',
        :name => "Bob Smith",
        :sex => 'male',
        :first_name => "Bob",
        :last_name => "Smith",
        :email => "bob@smith.net",
        :remote_id => 1234567,
        :profile_picture_url => 'http://blah.com/picture/blah',
        :locale => 'en_GB')
  
      # The user adds the tag 'lunch' to their favourites
       user.favourite_tags << lunch unless user.favourite_tags.include? lunch
       user.save!
  
      
      # now check - is the User saved to the database?
      bob = User.where(:username => 'bob').first
      assert bob != nil, "Expected bob to be non nil."
      assert bob.id == user.id, "Bob (id=#{bob.id}) was not the same as the created user (id=#{user.id}.)"
      assert bob.favourite_tags.include?(lunch), "expected bob to have favouite tag 'lunch'."
      
      # create a photo
      photo = Photo.create(:name => 'a test pic',
                           :caption => 'just testing',
                           :image_url => 'http://testing.photo/test1',
                           :thumbnail_url => 'http://testing.photo/test2',
                           :remote_id => 153)
      assert photo != nil, "expected photo to be non-nil."
      
      # add it to bob's list of photos.
      bob.photos << photo
      bob.save!

      # check the owner of the photo is bob.
      assert photo.owner == bob, "expected photo owner (#{photo.owner}) to be #{bob}."

      # create a preference and make it bob's.
      pref = Preference.create(:name => 'test', :value => 'test value')
      assert pref != nil, "expected pref to be non-nil."
      bob.preferences << pref
      bob.save!
      
      assert pref.user == bob, "expected the pref's user to be bob."

      # and finally shut it all down
      pref.destroy
      photo.destroy
      lunch.destroy
      user.destroy
    end
  end

end

