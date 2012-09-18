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
CoreIngredient.all.each do |ci|
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
tags = Tag.all.each do |t|
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
Ingredient.all.each do |i|
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

puts 'Database Extracted.'
