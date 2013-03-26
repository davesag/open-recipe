require 'test-unit'
require './test/handler_test_base'

class RecipeTest < HandlerTestBase

  # tests that we can create a recipe from a piece of JSON coming in from the server.
  def test_parse_recipe_from_json
  
    ne = 'test name'
    se = '6'
    cte = 120 * 60
    pte = 30 * 60
    de = "test description"
    me = "test method"
    re = "test req"

    # tags and meal nil for now.
    meale = nil
    tagse = nil

    # and active_ingredients
    ie = 'ing1'
    q_ae = '5'
    q_ue = '4'
  
    rjr = {"recipe"=>{"id"=>0, "name"=>ne, "serves" => se, "cooking_time"=>cte, "prep_time"=>pte, "description"=>de, "method"=>me, "requirements"=>re,
            "active_ingredients"=>[{"ingredient"=>ie, "quantity"=>{"amount"=>q_ae, "unit_id"=>q_ue}}],
            "tags"=>tagse, "meal"=>meale}, "path"=>"/recipe-request"}
    rj = check_param_not_nil rjr, 'recipe'

    n = check_param rj, 'name', ne
    s = check_param rj, 'serves', se
    ct = check_param rj, 'cooking_time', cte
    pt = check_param rj, 'prep_time', pte
    d = check_param rj, 'description', de
    m = check_param rj, 'method', me
    r = check_param rj, 'requirements', re

    # tags and meal nil for now.
    meal = check_param rj, 'meal', meale
    tags = check_param rj, 'tags', tagse

    # and active_ingredients
    ais = check_param_not_nil rj, 'active_ingredients'
    assert ais.length == 1, "expected only one ingredient."
    i = check_param ais[0], 'ingredient', ie
    q = check_param_not_nil ais[0], 'quantity'
    q_a = check_param q, 'amount', q_ae
    q_u = check_param q, 'unit_id', q_ue

    ActiveRecord::Base.transaction do |t|
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

      ingredient = Ingredient.where(:name => i).first_or_create
      quantity = Quantity.create(:amount => q_a,
                  :unit => AllowedUnit.where(:id => q_u.to_i).first_or_create(:name => 'test unit' << q_u.to_s))
      active_ingredient = ActiveIngredient.create(:ingredient => ingredient,
                                                  :quantity => quantity)
      recipe = Recipe.create(:owner => user, :name => n, :cooking_time => ct, :preparation_time => pt,
                              :serves => s.to_i, :description => d, :method => m, :active_ingredients => [active_ingredient],
                              :requirements => r)

      user.destroy
      # recipe.destroy
      # active_ingredient.destroy
      ingredient.destroy
      AllowedUnit.all.each {|au| au.destroy}
    end
    assert User.count == 0, "There #{User.count == 1 ? 'is' : 'are'} #{User.count} User#{User.count == 1 ? 'y' : 'ies'} left over."
    assert Quantity.count == 0, "There #{Quantity.count == 1 ? 'is' : 'are'} #{Quantity.count} Quantit#{Quantity.count == 1 ? 'y' : 'ies'} left over."
    assert Recipe.count == 0, "There #{Recipe.count == 1 ? 'is' : 'are'} #{Recipe.count} Recipe#{Recipe.count == 1 ? '' : 's'} left over."
    assert Ingredient.count == 0, "There #{Ingredient.count == 1 ? 'is' : 'are'} #{Ingredient.count} Ingredient#{Ingredient.count == 1 ? '' : 's'} left over."
    assert CoreIngredient.count == 0, "There #{CoreIngredient.count == 1 ? 'is' : 'are'} #{CoreIngredient.count} CoreIngredient#{CoreIngredient.count == 1 ? '' : 's'} left over."
    assert ActiveIngredient.count == 0, "There #{ActiveIngredient.count == 1 ? 'is' : 'are'} #{ActiveIngredient.count} ActiveIngredient#{ActiveIngredient.count == 1 ? '' : 's'} left over."
    assert AllowedUnit.count == 0, "There #{AllowedUnit.count == 1 ? 'is' : 'are'} #{AllowedUnit.count} AllowedUnit#{AllowedUnit.count == 1 ? '' : 's'} left over."
    assert Season.count == 0, "There #{Season.count == 1 ? 'is' : 'are'} #{Season.count} Season#{Season.count == 1 ? '' : 's'} left over."
    assert Tag.count == 0, "There #{Tag.count == 1 ? 'is' : 'are'} #{Tag.count} Tag#{Tag.count == 1 ? '' : 's'} left over."
  end

  def check_param_not_nil(a_map, a_param)
    assert a_map != nil, "[#{a_param}] : Expected the map you provided to be non-nil."
    assert a_map[a_param] != nil, "expected '#{a_param}' in map: #{a_map.inspect} to be non nil."
    return a_map[a_param]
  end

  def check_param (a_map, a_param, an_expected)
    assert a_map != nil, "[#{a_param}] : Expected the map you provided to be non-nil."
    return nil if a_map[a_param] == nil
    assert an_expected == a_map[a_param], "expected #{a_param} to be '#{an_expected}' but it was '#{a_map[a_param]}' in map #{a_map.inspect}"
    return a_map[a_param]
  end

end
