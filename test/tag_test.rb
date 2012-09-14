require 'koala'
require 'test-unit'
require './test/handler_test_base'

class TagTest < HandlerTestBase

  def test_tag_starts_with_and_name_contains
    ActiveRecord::Base.transaction do |t|
      tt = Tag.create(:name => "this is a test")
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"
      tt.name = "This is a test"
      tt.save!
      
      tr = Tag.name_starts_with('this').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'this', but got #{tr.name}"
      tr = Tag.name_starts_with('This').first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to start with 'This' after lowercase conversion, but got #{tr.name}"

      tr = Tag.name_starts_with("bingo").first
      assert tr == nil, "Expected no results."

      tr = Tag.name_contains("is a").first
      assert tr != nil, "expected search result to be non-nil"
      assert tt == tr, "expected the tag '#{tt.name}' to contain 'is a', but got #{tr.name}"

      tt.destroy
    end
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag#{Tag.count == 1 ? '' : 's'} left over."
  end

  def test_tag_in_use
    ActiveRecord::Base.transaction do |t|
      test_tags = []
      test_tags << tt = Tag.create(:name => "test")
      assert Tag.in_use.empty?, "Expected no tags to be in use."
      
      user = User.create(:username => 'bob',
        :name => "Bob Smith",
        :sex => 'male',
        :first_name => "Bob",
        :last_name => "Smith",
        :email => "bob@smith.net",
        :remote_id => 1234567,
        :profile_picture_url => 'http://blah.com/picture/blah',
        :locale => 'en_GB')

      user.favourite_tags << tt
      
      assert !Tag.in_use.empty?, "Expected the tag '#{tt.name}' to be in use."
      
      user.favourite_tags.delete tt
      assert Tag.in_use.empty?, "Expected no tags to be in use."      
      
      # ingredients
      ingredient = Ingredient.create(:name => "squirrel")
      metric = UnitType.create(:name => 'metric')
      allowed = AllowedUnit.create(:name => "g", :unit_type => metric)
      active_ingredient = ActiveIngredient.create(:ingredient => ingredient, :quantity => Quantity.create(:amount => 1, :unit => allowed))
      food = MealType.create(:name => 'food')
      meal = Meal.create(:name => "road kill stew", :description => "whatever you can scrape up", :meal_type => food)
      recipe = Recipe.create(:name => "road kill stew", :owner => user, :cooking_time => 130, :preparation_time => 90,
                            :serves => 4,
                            :description => "whatever you scrape together",
                            :requirements => "road kill and a pot",
                            :method => "chop up squirrel and cook in pot.",
                            :active_ingredients => [active_ingredient],
                            :meal => meal)
      # meals
      meal.tags << tt
      assert !Tag.in_use.empty?, "Expected the tag '#{tt.name}' to be in use."
      meal.tags.delete tt
            
      # recipes
      recipe.tags << tt
      assert !Tag.in_use.empty?, "Expected the tag '#{tt.name}' to be in use."

      test_tags << tv = Tag.create(:name => "veracity")
      test_tags << tc = Tag.create(:name => "chumps")
      
      recipe.tags << tv
      recipe.tags << tc
      
      tiu = Tag.in_use
      assert tiu.count == 3, "Expected three tags to be in use but only #{tiu.count == 1 ? 'one was' : tiu.count.to_s << ' were'}."
      assert tiu.first == tc, "Expected the tags to be sorted alphabetically but the first tag was #{tiu.first.name}"
      assert tiu.last == tv, "Expected the tags to be sorted alphabetically but the last tag was #{tiu.last.name}"

      recipe.tags.delete tt
      recipe.tags.delete tv
      recipe.tags.delete tc

      recipe.destroy
      meal.destroy
      food.destroy
      active_ingredient.destroy
      allowed.destroy
      metric.destroy
      ingredient.destroy
      user.destroy
      test_tags.each {|t| t.destroy }
    end
    assert ActiveIngredient.count == 0, "There #{ActiveIngredient.count == 1 ? 'are' : 's'} #{ActiveIngredient.count} ActiveIngredient#{ActiveIngredient.count == 1 ? '' : 's'} left over."
    assert AllowedUnit.count == 0, "There #{AllowedUnit.count == 1 ? 'are' : 's'} #{AllowedUnit.count} AllowedUnit#{AllowedUnit.count == 1 ? '' : 's'} left over."
    assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'are' : 's'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
    assert Meal.count == 0, "There #{Meal.count == 1 ? 'are' : 's'} #{Meal.count} Meal#{Meal.count == 1 ? '' : 's'} left over."
    assert MealType.count == 0, "There #{MealType.count == 1 ? 'are' : 's'} #{MealType.count} MealType#{MealType.count == 1 ? '' : 's'} left over."
    assert Recipe.count == 0, "There #{Recipe.count == 1 ? 'are' : 's'} #{Recipe.count} Recipe#{Recipe.count == 1 ? '' : 's'} left over."
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag#{Tag.count == 1 ? '' : 's'} left over."
    assert UnitType.count == 0, "There #{UnitType.count == 1 ? 'are' : 's'} #{UnitType.count} UnitType#{UnitType.count == 1 ? '' : 's'} left over."
    assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} user#{User.count == 1 ? '' : 's'} left over."
  end

end
