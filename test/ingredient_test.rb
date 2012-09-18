require 'koala'
require 'test-unit'
require './test/handler_test_base'

class IngredientTest < HandlerTestBase

  ## add tests for Photos linked to Ingredients and CoreIngredients too.

  # basic CI and I tests.
  def test_ingredients
    ActiveRecord::Base.transaction do |t|
      tt = Tag.create(:name => "this is a test")
      seasons = []
      seasons << summer = Season.create(:name => 'summer')
      seasons << spring = Season.create(:name => 'spring')
      seasons << autumn = Season.create(:name => 'autumn')
      seasons << winter = Season.create(:name => 'winter')
      
      ci = CoreIngredient.create(:name => 'spam', :energy => 150000,
                            :description => 'a tin of spam')
      ci.seasons << summer
      ci.seasons << spring
      ci.tags << tt
      ci.save
      assert ci.seasons.include?(spring), "Expected #{ci.name} to have season #{spring.name}"
      i = Ingredient.create(:name => 'spam', :core_ingredients => [ci],
                            :description => 'a tin of spam')
      assert i.tags.include?(tt), "Expected Ingredient '#{i.name}' to have tag '#{tt.name}. Our tags #{i.tags.inspect}, CoreIngredient.tags #{ci.tags.inspect}"
      assert i.core_ingredients.first == ci, "Expected Ingredient #{i.name} to have core ingredient #{ci.name} but found #{i.core_ingredients.inspect}"
      ai = ActiveIngredient.create(:ingredient => i)

      ai.destroy
      i.destroy
      ci.destroy
      seasons.each {|s| s.destroy }
      tt.destroy
    end
    assert ActiveIngredient.count == 0, "There #{ActiveIngredient.count == 1 ? 'is' : 'are'} #{ActiveIngredient.count} ActiveIngredient#{ActiveIngredient.count == 1 ? '' : 's'} left over."
    assert CoreIngredient.count == 0, "There #{CoreIngredient.count == 1 ? 'is' : 'are'} #{CoreIngredient.count} CoreIngredient#{CoreIngredient.count == 1 ? '' : 's'} left over."
    assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'is' : 'are'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
    assert Season.count == 0, "There #{Season.count == 1 ? 'is' : 'are'} #{Season.count} Season#{Season.count == 1 ? '' : 's'} left over."
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag#{Tag.count == 1 ? '' : 's'} left over."
  end

#   def test_can_match_simple_ingredient_to_core
#     ActiveRecord::Base.transaction do |t|
#       ci = CoreIngredient.create(:name => 'spam', :energy => 150000,
#                             :description => 'a tin of spam')
#       i = Ingredient.create(:name => 'spam', :description => "I don't like spam")
#       icis = i.match_core
#       assert icis.length == 1, "Expected one result but got #{icis.inspect}"
#       ici = icis[0]
#       assert ici == ci, "Expected CI #{ci.name} to match #{ici.name}"
#     end
#     assert CoreIngredient.count == 0, "There #{CoreIngredient.count == 1 ? 'is' : 'are'} #{CoreIngredient.count} CoreIngredient#{CoreIngredient.count == 1 ? '' : 's'} left over."
#     assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'is' : 'are'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
#   end

end
