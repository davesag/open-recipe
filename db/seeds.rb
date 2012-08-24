# load defaults for
# * meal_types
# * meals
# * units
# * unit_types
# * dependency_types
# * dependencies
# * tags
# * ingredients

puts "Seeding Unit Types, and Units."
unit_types = YAML.load(File.read('./config/units.yml'))

unit_types.each do |unit_type|
  key = unit_type.keys.first
  ut = UnitType.first_or_create(:name => key)
  
  unit_type[key].each do |unit|
    au = AllowedUnit.first_or_create({:name => unit.to_s}, {:unit_type => ut})
  end
end
puts "Units, and Unit Types seeded."

puts "Seeding Dependency Types."
dependency_types = YAML.load(File.read('./config/dependency_types.yml'))

dependency_types.each do |dt|
  key = dt.keys.first
  dtype = DependencyType.first_or_create({:name => key}, dt[key])
end
puts "Dependency Types seeded."

Tag.raise_on_save_failure = true

puts "Seeding Tags."
tags = YAML.load(File.read('./config/tags.yml'))

tags.each do |t|
  puts "Tag: #{t}"
  tag = Tag.first_or_create({:name => t})
end
puts "Tags seeded."

puts "Seeding Meal Types."
meal_types = YAML.load(File.read('./config/meal_types.yml'))

meal_types.each do |mt|
  mtype = MealType.first_or_create({:name => mt})
end
puts "Meal Types seeded."

puts "Seeding meals."
meals = YAML.load(File.read('./config/meals.yml'))
meals.each do |mhash|
  short_name = mhash.keys.first
  puts "short_name: #{short_name}"
  m = mhash[short_name]
  puts "m: #{m.inspect}"
  meal = Meal.first_or_create({:name => m['name']},
                              {:meal_type => MealType.first(:name => m['meal_type'])})
  # read in the tags
  tags = m['tags']
  tags.each do |t|
    tag = Tag.first_or_create({:name => t})
    meal.tags << tag unless meal.tags.include? tag
  end
  meal.save
end
puts "Meals seeded."

puts 'Database Seeded.'
