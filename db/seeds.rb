# Load basic defaults for data.
# this seeds.rb file is only run if there is no environment specific seeds file to run.
ActiveRecord::Base.transaction do |tran|
  puts "Seeding Unit Types, and Units."
  unit_types = YAML.load(File.read('./config/units.yml'))
  
  unit_types.each do |unit_type|
    key = unit_type.keys.first
    ut = UnitType.where(:name => key).first_or_create
    
    unit_type[key].each do |unit|
      au = AllowedUnit.where(:name => unit.to_s).first_or_create(:unit_type => ut)
    end
  end
  puts "Units, and Unit Types seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding Seasons."
  seasons = YAML.load(File.read('./config/seasons.yml'))
  
  seasons.each do |t|
    puts "Season: #{t}"
    season = Season.where(:name => t).first_or_create
  end
  puts "Seasons seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding Core Ingredients."
  core_ingredients = YAML.load(File.read('./config/core_ingredients.yml'))
  core_ingredients.each do |ihash|
    name = ihash.keys.first
    puts "name: #{name}"
    i = ihash[name]
    puts "i: #{i.inspect}"
  
    core_ingredient = CoreIngredient.where(:name => name).first_or_create
    core_ingredient.description = i['description'] unless i['description'] == nil
    core_ingredient.energy = i['energy'] unless i['energy'] == nil
    # read in the tags
    tags = i['tags']
    tags.each do |t|
      tag = Tag.where(:name => t).first_or_create
      core_ingredient.tags << tag unless core_ingredient.tags.include?(tag)
    end

    # now process seasons, either 'all' or comma separated list of season names.
    if 'all' == i['season']
      Season.all.each do |s|
        core_ingredient.seasons << s
      end
    else
      seasons = i['season'].split(',')
      seasons.each do |s|
        season = Season.find_by_name(s.strip)
        core_ingredient.seasons << season unless (season == nil || core_ingredient.seasons.include?(season))
      end
    end
    core_ingredient.save
  end
  puts "Core Ingredients seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding Tags."
  tags = YAML.load(File.read('./config/tags.yml'))
  
  tags.each do |t|
    puts "Tag: #{t}"
    tag = Tag.where(:name => t).first_or_create
  end
  puts "Tags seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding Meal Types."
  meal_types = YAML.load(File.read('./config/meal_types.yml'))
  
  meal_types.each do |mt|
    puts "Meal Type name is #{mt}"
    mtype = MealType.where(:name => mt).first_or_create
    puts "Database Meal Type is #{mtype.name}"
  end
  puts "Meal Types seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding meals."
  meals = YAML.load(File.read('./config/meals.yml'))
  meals.each do |mhash|
    short_name = mhash.keys.first
    puts "short_name: #{short_name}"
    m = mhash[short_name]
    puts "m: #{m.inspect}"
    puts "m['name'] = #{m['name']}"
    mt = MealType.where(:name => m['meal_type']).first
    puts "mt = #{mt}"
    meal = Meal.where(:name => m['name']).first_or_create
    meal.meal_type = mt
    meal.description = m['description']
    # read in the tags
    tags = m['tags']
    tags.each do |t|
      tag = Tag.where(:name => t).first_or_create
      meal.tags << tag unless meal.tags.include?(tag)
    end
    meal.save
  end
  puts "Meals seeded."
end

ActiveRecord::Base.transaction do |tran|
  puts "Seeding ingredients."
  ingredients = YAML.load(File.read('./config/ingredients.yml'))
  ingredients.each do |ihash|
    name = ihash.keys.first
    puts "name: #{name}"
    i = ihash[name]
    puts "i: #{i.inspect}"
  
    core_ingredient = CoreIngredient.match_core(i['core_ingredient'])
    puts "found core_ingredient #{core_ingredient.inspect}"

    ingredient = Ingredient.where(:name => name).first_or_create
    ingredient.description = i['description'] unless i['description'] == nil
    ingredient.core_ingredients = [core_ingredient] unless core_ingredient == nil
    # read in the tags
    tags = i['tags']
    if tags != nil
      tags.each do |t|
        tag = Tag.where(:name => t).first_or_create
        ingredient.tags << tag unless ingredient.tags.include?(tag)
      end
    end
    ingredient.save
    puts "ingredient #{ingredient.name} has core #{ingredient.core_ingredients.first.name}" unless ingredient.core_ingredients.empty?
    puts "ingredient #{ingredient.name} has no core" if ingredient.core_ingredients.empty?
  end
  puts "Ingredients seeded."
end

puts 'Database Seeded.'
