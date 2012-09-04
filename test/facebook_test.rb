require 'koala'
require 'test-unit'
require './test/handler_test_base'

class FacebookTest < HandlerTestBase

  APP_ID = 435425809841072 # the app's id
  APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

  # this test runs very slowly so only test when running full tests.
  def test_import_data_into_user_from_facebook
    # register your app at facebook to get these codes
    test_users = Koala::Facebook::TestUsers.new(:app_id => APP_ID, :secret => APP_CODE)
    users = []
    tu_extra = {}
    tu_extra['verified'] = true
    
    old_user_data = test_users.list.first
    if old_user_data == nil
      tu = user_from_facebook test_users
    else
      tu = user_from_facebook test_users,
                {"uid" => old_user_data['id'], "access_token" => old_user_data['token']}
    end
    bob = test_users.api.get_object(tu['id'].to_i)
    puts "loaded bob #{bob.inspect}"
    ActiveRecord::Base.transaction do |t|
      a_user = User.where(:remote_id => bob['id'].to_i).first_or_create
      assert !a_user.update_from_facebook(bob), "The test use is unvalidated by FB and so ought not be updated."
      
      users << bob = bob.merge(tu_extra)
      assert a_user.update_from_facebook(bob), "Could not update the user with validated data from Facebook's test user."
      a_user.save!
      
      # now remove the 'name' field. It should fail.
      bob['name'] = nil
      assert !a_user.update_from_facebook(bob), "Should not be able to update the user without name data from Facebook's test user."
      
      a_user.destroy
      assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} user#{User.count == 1 ? '' : 's'} left over."
      assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
    end
  end

  def user_from_facebook(test_users, token = nil)
    result = nil
    if token == nil
      result = test_users.create(true,
                    [ "read_friendlists", "publish_stream","email",
                      "user_likes", "user_checkins", "user_photos"])
    else
      begin
        result = test_users.create(true,
                      [ "read_friendlists", "publish_stream","email",
                        "user_likes", "user_checkins", "user_photos"], token)

      rescue Exception => detail
        puts "Invalid token #{token}."
        puts detail.inspect
        test_users.delete_all
        result = test_users.create(true,
                      [ "read_friendlists", "publish_stream","email",
                        "user_likes", "user_checkins", "user_photos"])
      end
    end
    return result
  end
  
end
