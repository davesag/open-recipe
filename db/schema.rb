# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2012082600) do

  create_table "active_ingredients", :force => true do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
    t.integer "quantity_id"
  end

  create_table "allowed_units", :force => true do |t|
    t.string  "name",         :limit => 25, :null => false
    t.integer "unit_type_id"
  end

  add_index "allowed_units", ["name"], :name => "index_allowed_units_on_name", :unique => true

  create_table "favourite_recipes", :force => true do |t|
    t.integer "recipe_id"
    t.integer "user_id"
    t.integer "rating"
  end

  create_table "favourite_restaurants", :force => true do |t|
    t.integer "restaurant_id"
    t.integer "user_id"
    t.integer "rating"
  end

  create_table "favourite_retailers", :force => true do |t|
    t.integer "retailer_id"
    t.integer "user_id"
    t.integer "rating"
  end

  create_table "ingredients", :force => true do |t|
    t.string  "name",        :null => false
    t.text    "description"
    t.integer "energy"
  end

  add_index "ingredients", ["name"], :name => "index_ingredients_on_name", :unique => true

  create_table "ingredients_photos", :id => false, :force => true do |t|
    t.integer "ingredient_id"
    t.integer "photo_id"
  end

  create_table "ingredients_recipes", :id => false, :force => true do |t|
    t.integer "ingredient_id"
    t.integer "recipe_id"
  end

  create_table "ingredients_retailers", :id => false, :force => true do |t|
    t.integer "ingredient_id"
    t.integer "retailer_id"
  end

  create_table "ingredients_tags", :id => false, :force => true do |t|
    t.integer "ingredient_id"
    t.integer "tag_id"
  end

  create_table "location_types", :force => true do |t|
    t.string  "name",                                 :null => false
    t.integer "effective_gps_radius", :default => 10
  end

  add_index "location_types", ["name"], :name => "index_location_types_on_name", :unique => true

  create_table "locations", :force => true do |t|
    t.string  "name",                                                              :null => false
    t.decimal "latitude",         :precision => 15, :scale => 10, :default => 0.0
    t.decimal "longitude",        :precision => 15, :scale => 10, :default => 0.0
    t.integer "remote_id"
    t.integer "location_type_id"
  end

  add_index "locations", ["name"], :name => "index_locations_on_name"
  add_index "locations", ["remote_id"], :name => "index_locations_on_remote_id", :unique => true

  create_table "meal_types", :force => true do |t|
    t.string "name", :limit => 12, :null => false
  end

  add_index "meal_types", ["name"], :name => "index_meal_types_on_name", :unique => true

  create_table "meals", :force => true do |t|
    t.string  "name",         :null => false
    t.text    "description"
    t.integer "meal_type_id"
  end

  add_index "meals", ["name"], :name => "index_meals_on_name", :unique => true

  create_table "meals_restaurants", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "meal_id"
  end

  create_table "meals_tags", :id => false, :force => true do |t|
    t.integer "meal_id"
    t.integer "tag_id"
  end

  create_table "photos", :force => true do |t|
    t.string  "name",          :null => false
    t.string  "caption"
    t.integer "owner_id"
    t.string  "image_url",     :null => false
    t.string  "thumbnail_url", :null => false
    t.text    "description"
    t.integer "remote_id"
  end

  add_index "photos", ["remote_id"], :name => "index_photos_on_remote_id", :unique => true

  create_table "photos_recipes", :id => false, :force => true do |t|
    t.integer "recipe_id"
    t.integer "photo_id"
  end

  create_table "photos_restaurants", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "photo_id"
  end

  create_table "photos_retailers", :id => false, :force => true do |t|
    t.integer "retailer_id"
    t.integer "photo_id"
  end

  create_table "preferences", :force => true do |t|
    t.string  "name",    :null => false
    t.string  "value"
    t.integer "user_id"
  end

  add_index "preferences", ["name"], :name => "index_preferences_on_name"

  create_table "quantities", :force => true do |t|
    t.integer "amount"
    t.integer "unit_id"
  end

  create_table "recipes", :force => true do |t|
    t.string  "name",             :null => false
    t.integer "cooking_time"
    t.integer "preparation_time"
    t.text    "requirements",     :null => false
    t.text    "description",      :null => false
    t.text    "method",           :null => false
    t.integer "owner_id",         :null => false
    t.integer "meal_id"
  end

  add_index "recipes", ["name"], :name => "index_recipes_on_name", :unique => true

  create_table "recipes_restaurants", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "recipe_id"
  end

  create_table "recipes_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "recipe_id"
  end

  create_table "restaurants", :force => true do |t|
    t.string  "name",        :null => false
    t.text    "description"
    t.integer "location_id"
    t.integer "remote_id"
  end

  add_index "restaurants", ["name"], :name => "index_restaurants_on_name"
  add_index "restaurants", ["remote_id"], :name => "index_restaurants_on_remote_id", :unique => true

  create_table "restaurants_tags", :id => false, :force => true do |t|
    t.integer "restaurant_id"
    t.integer "tag_id"
  end

  create_table "retailers", :force => true do |t|
    t.string  "name",        :null => false
    t.text    "description"
    t.integer "location_id"
    t.integer "remote_id"
  end

  add_index "retailers", ["name"], :name => "index_retailers_on_name"
  add_index "retailers", ["remote_id"], :name => "index_retailers_on_remote_id", :unique => true

  create_table "retailers_tags", :id => false, :force => true do |t|
    t.integer "retailer_id"
    t.integer "tag_id"
  end

  create_table "tags", :force => true do |t|
    t.string "name", :limit => 25, :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "tags_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "tag_id"
  end

  create_table "unit_types", :force => true do |t|
    t.string "name", :limit => 25, :null => false
  end

  add_index "unit_types", ["name"], :name => "index_unit_types_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string  "username",            :limit => 50
    t.string  "name",                :limit => 75
    t.string  "sex",                 :limit => 7
    t.string  "first_name",          :limit => 50
    t.string  "last_name",           :limit => 50
    t.string  "email",               :limit => 125
    t.integer "remote_id"
    t.string  "profile_picture_url"
    t.string  "locale",              :limit => 7
    t.integer "current_location"
  end

  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["remote_id"], :name => "index_users_on_remote_id", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
