require 'koala'
require 'test-unit'
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

      # Create some units and ingredients
      ingredients = []
      ingredients << frog = Ingredient.create(:name => "Frog (live)")
      ingredients << duck = Ingredient.create(:name => "BBQ Peking Duck")
      ingredients << salt = Ingredient.create(:name => "Salt")
      ingredients << pepper = Ingredient.create(:name => "Pepper")
      ingredients << water = Ingredient.create(:name => "Water")
      ingredients << wine = Ingredient.create(:name => "White Wine")
      ingredients << chinesespice = Ingredient.create(:name => "Star Anise")
      
      unit_types = []
      unit_types << metric = UnitType.create(:name => 'metric')
      unit_types << cooking = UnitType.create(:name => 'cooking')
      
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
                             :serves => 8,
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
                       :serves => 8,
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
      bob.favourite_recipes << frog_and_duck_soup
      assert bob.favourite_recipes.first.name == frog_and_duck_soup.name, "expected bob's fave to be frog and duck soup but it was #{bob.favourite_recipes.first.name}."

      # and finally shut it all down

      allowed_units.each {|t| t.destroy}
      recipes.each {|t| t.destroy}
      tags.each {|t| t.destroy}
      active_ingredients.each {|t| t.destroy}
      ingredients.each {|t| t.destroy}
      meals.each {|t| t.destroy}
      meal_types.each {|t| t.destroy}
      unit_types.each {|t| t.destroy}
      user.destroy
      assert ActiveIngredient.count == 0, "There #{ActiveIngredient.count == 1 ? 'are' : 's'} #{ActiveIngredient.count} ActiveIngredient#{ActiveIngredient.count == 1 ? '' : 's'} left over."
      assert AllowedUnit.count == 0, "There #{AllowedUnit.count == 1 ? 'are' : 's'} #{AllowedUnit.count} AllowedUnit#{AllowedUnit.count == 1 ? '' : 's'} left over."
      assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'are' : 's'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
      assert Meal.count == 0, "There #{Meal.count == 1 ? 'are' : 's'} #{Meal.count} Meal#{Meal.count == 1 ? '' : 's'} left over."
      assert MealType.count == 0, "There #{MealType.count == 1 ? 'are' : 's'} #{MealType.count} MealType#{MealType.count == 1 ? '' : 's'} left over."
      assert Photo.count == 0, "Expected the photos to be gone."
      assert Preference.count == 0, "Expected the preferences to be gone."
      assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag type#{Tag.count == 1 ? '' : 's'} left over."
      assert UnitType.count == 0, "There #{UnitType.count == 1 ? 'are' : 's'} #{UnitType.count} UnitType#{UnitType.count == 1 ? '' : 's'} left over."
      assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} user#{User.count == 1 ? '' : 's'} left over."
    end
  end
end
