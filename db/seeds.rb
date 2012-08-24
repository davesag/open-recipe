# load defaults for
# * meal_types
# * meals
# * units
# * unit_types
# * dependency_types
# * dependencies
# * tags
# * ingredients

# units types, and units
unit_types = YAML.load(File.read('./config/units.yml'))

unit_types.each do |unit_type|
  key = unit_type.keys.first
  puts "#{key} : #{unit_type[key].inspect}"
  ut = UnitType.first_or_create(:name => key)
  
  puts key
  unit_type[key].each do |unit|
    au = AllowedUnit.first_or_create({:name => unit.to_s}, {:unit_type => ut})
  end
  puts "#{ut.name} : #{ut.allowed_units.inspect}"
end

# dependency types
dependency_types = YAML.load(File.read('./config/dependency_types.yml'))

dependency_types.each do |dt|
  key = dt.keys.first
  puts "#{key} : #{dt[key].inspect}"
  dtype = DependencyType.first_or_create({:name => key}, dt[key])
end
puts 'Database Seeded.'
