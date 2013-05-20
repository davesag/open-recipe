require 'unicode'

# Export seed data from the database.
Dir.mkdir('./extracts') unless File.exists?('./extracts');

puts "Extracting Unit Types, and Units."
result = []
unit_types = UnitType.all.each do |unit_type|
  aus = unit_type.allowed_units
  au_names = []
  aus.each do |au|
    au_names << au.name
  end
  result << { unit_type.name => au_names }
end
file = File.open('./extracts/units.yml', 'w')
file.write(result.to_yaml)
puts "Units, and Unit Types Extracted."

puts "Extracting Seasons."
result = []
Season.all.each do |t|
  result << t.name
end
file = File.open('./extracts/seasons.yml', 'w')
file.write(result.to_yaml)
puts "Seasons extracted."

puts "Extracting Core Ingredients."
result = []
CoreIngredient.find(:all, :order=>"name ASC").each do |ci|
  tag_names = []
  ci.tags.all.each {|t| tag_names << t.name}
  if ci.seasons.length == 4
    season = 'all'
  else
    season = ''
    ci.seasons.each {|s| season << "#{s.name}, " }
    season.strip!.chomp! ','
  end
  if ci.energy == nil
    result << { ci.name => {'description' => ci.description,
                             'tags' => tag_names, 'season' => season }}
  else
    result << { ci.name => {'description' => ci.description, 'energy' => ci.energy,
                             'tags' => tag_names, 'season' => season }}
  end
end
file = File.open('./extracts/core_ingredients.yml', 'w')
file.write(result.to_yaml)
puts "Core Ingredients seeded."

puts "Extracting Tags."
result = []
tags = Tag.find(:all, :order=>"name ASC").each do |t|
  result << t.name
end

file = File.open('./extracts/tags.yml', 'w')
file.write(result.to_yaml)
puts "Tags extracted."

puts "Extracting Meal Types."
result = []
MealType.all.each do |mt|
  result << mt.name
end
file = File.open('./extracts/meal_types.yml', 'w')
file.write(result.to_yaml)
puts "Meal Types extracted."

puts "Extracting Meals."
result = []
Meal.all.each do |m|
  short_name = Unicode::downcase(m.name.gsub(/\s+/, ""))
  puts "short_name: #{short_name}"
  tag_names = []
  m.tags.each { |t| tag_names << t.name }
  result << {short_name => { 'name' => m.name,
                             'description' => m.description,
                             'tags' => tag_names,
                             'meal_type' => m.meal_type.name }}
end
file = File.open('./extracts/meals.yml', 'w')
file.write(result.to_yaml)
puts "Meals Extracted."

puts "Extracting Ingredients."
result = []
Ingredient.find(:all, :order=>"name ASC").each do |i|
  # remove the tags that are in the core.
  tags = i.tags - i.core_ingredients.first.tags unless i.core_ingredients.empty?
  tags = i.tags if i.core_ingredients.empty?
  tag_names = []
  if !tags.empty?
    tags.each { |t| tag_names << t.name }
  end
  puts "Extracting Ingredient named '#{i.name}'"
  puts "Which has core ingredients #{i.core_ingredients.inspect}"
  r = { 'description' => i.description }
  r['core_ingredient'] = i.core_ingredients.first.name unless i.core_ingredients.empty?
  r['tags'] = tag_names unless tag_names.empty?
  result << { i.name => r }
end
file = File.open('./extracts/ingredients.yml', 'w')
file.write(result.to_yaml)
puts "Ingredients Extracted."

puts "Extracting Users."
result = []
User.find(:all, :order=>"name ASC").each do |i|
  r = {
    'name' => i.name,
    'sex' => i.sex,
    'first_name' => i.first_name,
    'last_name' => i.last_name,
    'email' => i.email,
    'username' => i.username,
    'profile_picture_url' => i.profile_picture_url,
    'locale' => i.locale
  }
  # what to do with favourite recipes?
  result << { i.remote_id => r }
end
file = File.open('./extracts/users.yml', 'w')
file.write(result.to_yaml)
puts "Users Extracted."

puts "Extracting Photos."
result = []
Photo.find(:all, :order=>"remote_id ASC").each do |i|
  r = {
    'name' => i.name,
    'owner' => i.owner.remote_id,
    'image_url' => i.image_url,
    'thumbnail_url' => i.thumbnail_url
  }
  result << { i.remote_id => r }
end
file = File.open('./extracts/photos.yml', 'w')
file.write(result.to_yaml)
puts "Photos Extracted."

puts "Extracting Recipes."
result = []
Recipe.find(:all, :order=>"name ASC").each do |i|
  faves = []
  i.users.each { |u| faves << u.remote_id }
  r = {
    'owner' => i.owner.remote_id,
    'name' => i.name,
    'serves' => i.serves,
    'cooking_time' => i.cooking_time,
    'preparation_time' => i.preparation_time,
    'description' => i.description.squeeze(' ').strip,
    'method' => i.method.strip,
    'requirements' => i.requirements.strip,
    'photo' => (i.photos.empty?) ? nil : i.photos[0].remote_id,
    'users' => faves
  }
  tags = i.tags
  tag_names = []
  if !tags.empty?
    tags.each { |t| tag_names << t.name }
  end
  r['tags'] = tag_names
  ais = i.active_ingredients
  ings = []
  if !ais.empty?
    ais.each do |ai|
      ings << {
        'name' => ai.ingredient.name,
        'quantity' => (ai.quantity) ? {
          'unit' => (ai.quantity.unit) ? ai.quantity.unit.name : nil,
          'amount' => (ai.quantity.amount) ? ai.quantity.amount : nil
        } : nil
      }
    end
    r['active_ingredients'] = ings
  end
  result << { i.name => r }
end
file = File.open('./extracts/recipes.yml', 'w')
file.write(result.to_yaml)
puts "Recipes Extracted."

puts 'Database Extracted.'
