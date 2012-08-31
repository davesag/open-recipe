require 'koala'
require 'test-unit'
require './test/handler_test_base'

class UserTest < HandlerTestBase

  APP_ID = 435425809841072 # the app's id
  APP_CODE = 'b8c359ffe13e3ed7e90670e4bb5ec5bd' # the app's secret code

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


      # Create some units and ingredients
      ingredients = []
      ingredients << frog = Ingredient.create(:name => "Frog (live)")
      ingredients << duck = Ingredient.create(:name => "BBQ Peking Duck")
      ingredients << salt = Ingredient.create(:name => "Salt")
      ingredients << pepper = Ingredient.create(:name => "Pepper")
      ingredients << water = Ingredient.create(:name => "Water")
      ingredients << wine = Ingredient.create(:name => "White Wine")
      ingredients << chinesespice = Ingredient.create(:name => "Star Anise")
      
      metric = UnitType.create(:name => 'metric')
      cooking = UnitType.create(:name => 'cooking')
      
      allowed_units =[]
      allowed_units << none_unit = AllowedUnit.create(:name => 'none', :unit_type => nil)
      allowed_units << totaste_unit = AllowedUnit.create(:name => ' to taste', :unit_type => nil)
      allowed_units << mm_unit = AllowedUnit.create(:name => 'mm', :unit_type => metric)
      allowed_units << pinch_unit = AllowedUnit.create(:name => 'pinch', :unit_type => cooking)
      allowed_units << cup_unit = AllowedUnit.create(:name => 'cup', :unit_type => cooking)
      allowed_units << mm_unit = AllowedUnit.create(:name => 'mm', :unit_type => metric)
      allowed_units << ml_unit = AllowedUnit.create(:name => 'ml', :unit_type => metric)
      
      active_ingredients = []
      active_ingredients << ActiveIngredient.create(:ingredient => frog,
                          :quantity => Quantity.create(:amount => 1, :unit => none_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => duck,
                           :quantity => Quantity.create(:amount => 1, :unit => none_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => water,
                           :quantity => Quantity.create(:amount => 2500, :unit => ml_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => wine,
                           :quantity => Quantity.create(:amount => 1, :unit => cup_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => chinesespice,
                           :quantity => Quantity.create(:amount => 1, :unit => pinch_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => salt,
                           :quantity => Quantity.create(:amount => 1, :unit => totaste_unit))
      active_ingredients << ActiveIngredient.create(:ingredient => pepper,
                           :quantity => Quantity.create(:amount => 1, :unit => totaste_unit))

      tags = []
      tags << lunch
      tags << dinner = Tag.where(:name => 'dinner').first_or_create
      tags << chinese = Tag.where(:name => 'Chinese').first_or_create
      tags << soup = Tag.where(:name => 'soup').first_or_create
      tags << easy = Tag.where(:name => 'easy').first_or_create
      
      meal_types =[]
      meal_types << food = MealType.create(:name => 'food')
      
      meals =[]
      meals << duck_soup = Meal.create(:name => "Duck Soup", :description => "Duck in soup.",
                                      :tags => [soup, lunch, dinner],
                                      :meal_type => food)
      
      # Create a recipe
      recipes = []
      recipes << frog_and_duck_soup = Recipe.create(:name => 'Frog and Duck Soup - Dave\'s Style',
                             :owner => bob,
                             :cooking_time => 90, :preparation_time => 20,
                             :description => "A deliciously tangy soup made from chinese roasted duck and boiled frogs.",
                             :requirements => "A frog caught from a creek or stream, and a BBQ Peking Duck, are the main things you'll need.",
                             :method => "Chop up the {duck} and throw into hot pan. Add water to cover. Then add the {frog}. Cover with {water} and boil for 5 minutes, to ensure the {frog} is dead. Simmer for an hour and a half. Serve hot with chopped up garlic and edible flowers.",
                             :active_ingredients => active_ingredients,
                             :tags => [dinner,chinese,soup,easy],
                             :meal => duck_soup)
      
      active_ingredients_2 = []
      active_ingredients_2 << ActiveIngredient.create(:ingredient => frog,
                          :quantity => Quantity.create(:amount => 1, :unit => none_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => duck,
                           :quantity => Quantity.create(:amount => 1, :unit => none_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => water,
                           :quantity => Quantity.create(:amount => 2500, :unit => ml_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => wine,
                           :quantity => Quantity.create(:amount => 1, :unit => cup_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => chinesespice,
                           :quantity => Quantity.create(:amount => 1, :unit => pinch_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => salt,
                           :quantity => Quantity.create(:amount => 1, :unit => totaste_unit))
      active_ingredients_2 << ActiveIngredient.create(:ingredient => pepper,
                           :quantity => Quantity.create(:amount => 1, :unit => totaste_unit))

      recipes << duck_and_frog_soup = Recipe.create(:name => 'Duck and Frog Soup',
                       :owner => bob,
                       :cooking_time => 90, :preparation_time => 20,
                       :description => "A delightfully flavoursome soup made from chinese roasted duck and a frogs.",
                       :requirements => "A frog caught from a garden or drain, and a BBQ Peking Duck, are the main things you'll need.",
                       :method => "Chop up the {duck} and throw into hot pan. Add water to cover. Then add the {frog}. Cover with {water} and boil for 5 minutes, to ensure the {frog} is dead. Simmer for an hour and a half. Serve hot with chopped up garlic and edible flowers.",
                       :active_ingredients => active_ingredients_2,
                       :tags => [dinner,chinese,soup,easy],
                       :meal => duck_soup)

      assert bob.recipes.include?(frog_and_duck_soup), "expected bob's recipe list would include #{frog_and_duck_soup.name}."
      assert bob.recipes.include?(duck_and_frog_soup), "expected bob's recipe list would include #{duck_and_frog_soup.name}."
      assert dinner.recipes.include?(frog_and_duck_soup), "Expected the tag 'dinner' to include recipe #{frog_and_duck_soup.name}"
      assert frog_and_duck_soup.active_ingredients.first.quantity.amount == 1, "Expected one frog but it got #{frog_and_duck_soup.active_ingredients.first.quantity.amount}"
      assert frog_and_duck_soup.active_ingredients.first.ingredient == frog, "Expected it to be a frog."
      assert easy.recipes.include?(frog_and_duck_soup), "expected frog and duck soup to be easy"
      
      # favourite_recipes
      favourite_recipes = []
      favourite_recipes << fav_frog_and_duck_soup = FavouriteRecipe.create(:recipe => frog_and_duck_soup, :rating => 7, :user => bob)
      assert bob.favourite_recipes.first.recipe.name == frog_and_duck_soup.name, "expected bob's fave to be frog and duck soup but it was #{bob.favourite_recipes.first.recipe.name}."
      assert bob.favourite_recipes.first.rating == 7, "expetced it to have a rating of 7 but it was #{bob.favourite_recipes.first.rating}."

      #location_types
      location_types = []
      location_types << city = LocationType.create(:name => 'City', :effective_gps_radius => 1000)
      location_types << outdoors = LocationType.create(:name => 'Outdoors', :effective_gps_radius => 1000)
      location_types << restaurant = LocationType.create(:name => 'Restaurant', :effective_gps_radius => 50)
      location_types << shop = LocationType.create(:name => 'Shop', :effective_gps_radius => 50)
      location_types << mall = LocationType.create(:name => 'Shopping Mall', :effective_gps_radius => 500)

      # locations
      locations = []
      locations << some_damn_place = Location.create(:name => "some damn place",
                                    :latitude => 35.545426,
                                    :longitude => 22.6353363,
                                    :location_type => outdoors,
                                    :remote_id => 3)
      locations << canberra = Location.create(:name => "Canberra",
                                    :latitude => 35.545426,
                                    :longitude => 22.6353363,
                                    :location_type => city,
                                    :remote_id => 5)
      locations << the_mall = Location.create(:name => "The Shops",
                                    :latitude => 35.545426,
                                    :longitude => 22.6353363,
                                    :location_type => mall,
                                    :remote_id => 7)
      locations << the_shop = Location.create(:name => "Shop 3, Shopping Street.",
                                    :latitude => 35.545426,
                                    :longitude => 22.6353363,
                                    :location_type => shop,
                                    :remote_id => 9)
      locations << the_restaurant = Location.create(:name => "Shop 3, Shopping Street.",
                                    :latitude => 35.545426,
                                    :longitude => 22.6353363,
                                    :location_type => restaurant,
                                    :remote_id => 11)

      # restaurants
      restaurants = []
      restaurants << wok_on_buy = Restaurant.create(:name => 'Wok On Buy', :description => 'A lovely little place to buy chinese.',
                                                    :meals => [duck_soup],
                                                    :photos => [photo],
                                                    :tags => [chinese, dinner],
                                                    :recipes => [duck_and_frog_soup],
                                                    :location => the_restaurant)

      # favourite_restaurants
      favourite_restaurants = []
      favourite_restaurants << fav_chinese = FavouriteRestaurant.create(:restaurant => wok_on_buy, :rating => 8, :user => bob)
      assert bob.favourite_restaurants.first.restaurant.name == wok_on_buy.name, "expected bob's fave to be #{wok_on_buy.name} but it was #{bob.favourite_restaurants.first.restaurant.name}."
      assert bob.favourite_restaurants.first.rating == 8, "expetced it to have a rating of 8 but it was #{bob.favourite_restaurants.first.rating}."

      # with photos
      assert photo.restaurants.first == wok_on_buy, "expected the photo to be linked to Wok On Buy."
      
      # with recipes
      assert duck_and_frog_soup.restaurants.first == wok_on_buy, "expected recipe #{duck_and_frog_soup.name}to be linked to #{wok_on_buy.name}"
      
      # with tags
      assert chinese.restaurants.first == wok_on_buy, "expected tag #{chinese.name}to be linked to #{wok_on_buy.name}"
      # with meals
      
      # retailers
      retailers = []
      retailers << wokking_shop = Retailer.create(:name => 'Wokking Shop', :description => 'A lovely little place to buy wholesale chinese.',
                                                    :tags => [chinese],
                                                    :ingredients => [duck, chinesespice, salt, pepper],
                                                    :location => the_shop)

      # favourte_retailers
      favourite_retailers = []
      favourite_retailers << fav_chinese = FavouriteRetailer.create(:retailer => wokking_shop, :rating => 4, :user => bob)
      assert bob.favourite_retailers.first.retailer.name == wokking_shop.name, "expected bob's fave to be #{wokking_shop.name} but it was #{bob.favourite_retailers.first.retailer.name}."
      assert bob.favourite_retailers.first.rating == 4, "expetced it to have a rating of 4 but it was #{bob.favourite_retailers.first.rating}."

      bob.current_location = the_restaurant
      bob.save!
      assert the_restaurant.users.include?(bob), "expected bob to be in the list of users for #{the_restaurant.name}"

      # and finally shut it all down

      location_types.each {|t| t.destroy}
      locations.each {|t| t.destroy}
      restaurants.each {|t| t.destroy}
      recipes.each {|t| t.destroy}
      retailers.each {|t| t.destroy}
      tags.each {|t| t.destroy}
      active_ingredients.each {|t| t.destroy}
      ingredients.each {|t| t.destroy}
      user.destroy
      assert FavouriteRecipe.count == 0, "Expected the favourite recipes to be gone but there #{FavouriteRecipe.count == 1 ? 'was' : 'were'} #{FavouriteRecipe.count} left."
      assert FavouriteRestaurant.count == 0, "Expected the favourite restaurants to be gone but there #{FavouriteRestaurant.count == 1 ? 'was' : 'were'} #{FavouriteRestaurant.count} left."
      assert Photo.count == 0, "Expected the photos to be gone."
      assert Preference.count == 0, "Expected the preferences to be gone."
      assert Location.count == 0, "There #{Location.count == 1 ? 'are' : 's'} #{Location.count} location#{Location.count == 1 ? '' : 's'} left over."
      assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} user#{User.count == 1 ? '' : 's'} left over."
      assert LocationType.count == 0, "There #{LocationType.count == 1 ? 'is' : 'are'} #{LocationType.count} location type#{LocationType.count == 1 ? '' : 's'} left over."
      assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
    end
  end

  # this test runs very slowly so only test when running full tests.
  def x_test_import_data_into_user_from_facebook
    # register your app at facebook to get these codes
    test_users = Koala::Facebook::TestUsers.new(:app_id => APP_ID, :secret => APP_CODE)
    users = []
    tu_extra = {}
    tu_extra['verified'] = true
    tu_extra['location'] = {:name => "Canberra, Australian Capital Territory", :id => 106270089409734}
    
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
      
      bob_loc = bob['location']
      assert bob_loc != nil, "There should be a location but bob was #{bob.inspect}"
      loc = Location.where(:name => bob_loc[:name]).first_or_create
      puts "bob_loc = #{bob_loc.inspect}"
# facebook's test api doesn't allow for such tests. see github at 
#       bob_loc_detail = test_users.api.get_object(bob_loc['id'])
#       assert bob_loc_detail != nil, "There should be more location details but bob's location id #{bob_loc['id']} didn't return anything."
#       assert loc.update_from_facebook(bob_loc_detail), "Could not update location details from facebook."
      loc.users << a_user
      loc.save!
      assert a_user.current_location == loc, "expected #{a_user.first_name}'s current location to be #{loc} but it was #{a_user.current_location}"
      # teardown
      LocationType.all.each {|t| t.destroy}
      loc.destroy
      a_user.destroy
      assert Location.count == 0, "There #{Location.count == 1 ? 'is' : 'are'} #{Location.count} location#{Location.count == 1 ? '' : 's'} left over."
      assert LocationType.count == 0, "There #{LocationType.count == 1 ? 'is' : 'are'} #{LocationType.count} location type#{LocationType.count == 1 ? '' : 's'} left over."
      assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} user#{User.count == 1 ? '' : 's'} left over."
      assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
    end
  end

  def user_from_facebook(test_users, token = nil)
    result = nil
    if token == nil
      result = test_users.create(true,
                    [ "read_friendlists", "publish_stream","email","user_location",
                      "user_likes", "user_checkins", "user_photos"])
    else
      begin
        result = test_users.create(true,
                      [ "read_friendlists", "publish_stream","email","user_location",
                        "user_likes", "user_checkins", "user_photos"], token)

      rescue Exception => detail
        puts "Invalid token #{token}."
        puts detail.inspect
        test_users.delete_all
        result = test_users.create(true,
                      [ "read_friendlists", "publish_stream","email","user_location",
                        "user_likes", "user_checkins", "user_photos"])
      end
    end
    return result
  end
  
  def test_tag_starts_with
    ActiveRecord::Base.transaction do |t|
      tt = Tag.create(:name => "this is a test")
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"
      tt..name = "This is a test"
      tt.save!
      
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"

      tr = Tag.name_starts_with("bingo").first
      assert tr == nil, "Expected no results."

      tt.destroy
    end
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
  end
end
