require 'koala'
require 'test-unit'
require './test/handler_test_base'

class IngredientTest < HandlerTestBase

  def test_ingredients
    ActiveRecord::Base.transaction do |t|
      tt = Tag.create(:name => "this is a test")
      seasons = []
      seasons << summer = Season.create(:name => 'summer')
      seasons << spring = Season.create(:name => 'spring')
      seasons << autumn = Season.create(:name => 'autumn')
      seasons << winter = Season.create(:name => 'winter')
      
      i = Ingredient.create(:name => 'spam', :energy => 150000,
                            :description => 'a tin of spam')
      i.tags << tt
      assert i.tags.include?(tt), "Expected #{i.name} to have tag #{tt.name}"
      
      i.seasons << summer
      i.seasons << spring
      assert i.seasons.include?(spring), "Expected #{i.name} to have season #{spring.name}"

      p = Preparation.create(:name => 'sliced')
      ai = ActiveIngredient.create(:ingredient => i, :preparation => p)
      assert p.active_ingredients.include?(ai), "Expected Preparation #{p.name} to be linked to #{ai.ingredient.name}"

      ai.destroy
      p.destroy
      i.destroy
      seasons.each {|s| s.destroy }
      tt.destroy
    end
    assert ActiveIngredient.count == 0, "There #{ActiveIngredient.count == 1 ? 'is' : 'are'} #{ActiveIngredient.count} ActiveIngredient#{ActiveIngredient.count == 1 ? '' : 's'} left over."
    assert Preparation.count == 0, "There #{Preparation.count == 1 ? 'is' : 'are'} #{Preparation.count} Preparation#{Preparation.count == 1 ? '' : 's'} left over."
    assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'is' : 'are'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
    assert Season.count == 0, "There #{Season.count == 1 ? 'is' : 'are'} #{Season.count} Season#{Season.count == 1 ? '' : 's'} left over."
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} tag#{Tag.count == 1 ? '' : 's'} left over."
  end

end
