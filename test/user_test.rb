require 'test/unit'
require 'rack/test'
require './test/handler_test_base'

class UserTest < HandlerTestBase

  #test creation of Users and related objects.
  def test_create_user

    User.raise_on_save_failure = true  # while debugging.
    User.transaction do |t|
      # create a tag
      lunch = Tag.create(:name => 'lunch')
      assert lunch != nil, "Expected lunch to be non nil."
      loaded_lunch = Tag.first(:name => 'lunch')
      assert loaded_lunch != nil, "Expected loaded_lunch to be non nil."
      assert loaded_lunch.id == lunch.id, "The loaded lunch was not the same as the created lunch."
  
      # create a User
      user = User.create({:username => 'bob',
        :name => "Bob Smith",
        :sex => 'male',
        :first_name => "Bob",
        :last_name => "Smith",
        :email => "bob@smith.net",
        :remote_id => 1234567,
        :profile_picture_url => 'http://blah.com/picture/blah',
        :locale => 'en_GB'}
      )
  
      # The user adds the tag 'lunch' to their favourites
       user.favourite_tags << lunch unless user.favourite_tags.include? lunch
       user.save
  
      # now check - is the Tag saved to the database?
      
      # now check - is the User saved to the database?
      bob = User.first(:username => 'bob')
      assert bob != nil, "Expected bob to be non nil."
      assert bob.favourite_tags.include? "lunch", "expected bob to have favouite tag 'lunch'."
      
      # and finally shut it all down
      lunch.destroy
      user.destroy
    end
  end

end

