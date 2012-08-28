#!usr/bin/ruby

class InitialModels < ActiveRecord::Migration
  def self.up
    create_table :allowed_units do |t|
      t.string  :name, :null => false, :limit => 25
      t.integer :unit_type_id       #allowed_unit belongs_to :unit_type
                                    #unit_types has_many :allowed_units
    end

    add_index :allowed_units, :name, :unique => true

    create_table :unit_types do |t|
      t.string :name, :null => false, :limit => 25
    end

    add_index :unit_types, :name, :unique => true

    create_table :ingredients do |t|
      t.string   :name, :null => false, :limit => 255
      t.text     :description
      t.integer  :energy            # joules per 100g consumed
                                    # ingredient has_and_belongs_to_many :recipes (These are the recipes to make this ingredient.)
                                    # recipe has_and_belongs_to_many :tags
                                    # has_many :active_ingredients

    end

    add_index :ingredients, :name, :unique => true

    create_table :recipes do |t|
      t.string  :name, :null => false, :limit => 255
      t.integer :cooking_time
      t.integer :preparation_time
      t.text    :requirements, :null => false
      t.text    :description, :null => false
      t.text    :method, :null => false
      t.integer :owner_id, :null => false
                                    # recipe belongs_to :owner, :class_name => 'User'
                                    # recipe has_many :active_ingredients
                                    # recipe has_and_belongs_to_many :tags
                                    # recipe has_and_belongs_to_many :restaurants
      t.integer :meal_id            # recipe belongs_to :meal
                                    # meal has_many :recipes
    end
    
    add_index :recipes, :name, :unique => true

    # ingredient has_and_belongs_to_many :recipes (These are the recipes to make this ingredient.)
    # recipe has_and_belongs_to_many :ingredients (These are the recipes to make this ingredient.)
    create_table :ingredients_recipes, :id => false do |t|
      t.integer  :ingredient_id
      t.integer  :recipe_id
    end

    create_table :active_ingredients do |t|
      t.integer  :recipe_id       # belongs_to :recipe
                                  # the recipe being made with this ingredient
      t.integer  :ingredient_id   # belongs_to :ingredient
                                  # the ingredient to use
      t.integer  :quantity_id     # belongs_to :quantity
                                  # the amount and units used
    end

    create_table :ingredients_tags, :id => false do |t|
      t.integer  :ingredient_id
      t.integer  :tag_id
    end

    create_table :users do |t|
      t.string   :username, :limit => 50
      t.string   :name, :limit => 75
      t.string   :sex, :limit => 7
      t.string   :first_name, :limit => 50
      t.string   :last_name, :limit => 50
      t.string   :email, :limit => 125
      t.integer  :remote_id
      t.string   :profile_picture_url, :limit => 255
      t.string   :locale, :limit => 7
                                  # user has_many :recipes
                                  # user has_many :favourite_recipes
                                  # user has_many :favourite_restaurants
                                  # user has_many :favourite_retailers
                                  # user has_many :photos.
                                  # user has_and_belongs_to_many :favourite_tags, :class_name => 'Tag'
    end

    add_index :users, :name, :unique => false
    add_index :users, :username, :unique => true
    add_index :users, :remote_id, :unique => true

    create_table :meals do |t|
      t.string   :name, :null => false, :limit => 255
      t.text     :description
                                    # meal has_many :recipes
                                    # recipe belongs_to :meal
      t.integer  :meal_type_id
                                    # meal belongs_to :meal_type
                                    # meal_type has_many :meals
      
    end

    add_index :meals, :name, :unique => true

    create_table :meal_types do |t|
      t.string   :name, :null => false, :limit => 12
                                    # meal_type has_many :meals
                                    # meal belongs_to :meal_type
      
    end

    add_index :meal_types, :name, :unique => true
    
    create_table :tags do |t|
      t.string   :name, :null => false, :limit => 25
                                  # tag has_and_belongs_to_many :users
    end
    
    add_index :tags, :name, :unique => true

    # tags have users and users have favourite_tags
    create_table :tags_users, :id => false do |t|
      t.integer  :user_id
      t.integer  :tag_id
    end

    # tags have meals and meals have tags
    create_table :meals_tags, :id => false do |t|
      t.integer  :meal_id
      t.integer  :tag_id
    end

    create_table :recipes_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :recipe_id
    end

    create_table :favourite_recipes do |t|
      t.integer :recipe_id      # favourite_recipe belongs_to :recipe
                                # recipe has_many :favourite_recipes
      t.integer :user_id        # favourite_recipe belongs_to :users
                                # user has_many :favourite_recipes
      t.integer :rating         # the rating the user gives the recipe. (aggregated to compute recipe's average rating.)
    end

    create_table :quantities do |t|
      t.integer :amount
      t.integer :unit_id        # quantity belongs_to :unit
    end

    create_table :locations do |t|
      t.string   :name, :null => false
      t.decimal  :latitude, :precision => 15, :scale => 10, :default => 0.0
      t.decimal  :longitude, :precision => 15, :scale => 10, :default => 0.0
      t.integer  :remote_id
      t.integer  :location_type_id # location belongs_to location_type
                                   # location_type has_many locations
                                   # location has_many retailers
                                   # location has_many restaurants
    end

    add_index :locations, :name, :unique => false
    add_index :locations, :remote_id, :unique => true

    create_table :location_types do |t|
      t.string :name, :null => false
      t.integer :effective_gps_radius, :default => 10 # metres.
    end

    add_index :location_types, :name, :unique => true

    create_table :restaurants do |t|
      t.string   :name, :null => false
      t.text     :description
      t.integer  :location_id     # restaurant belongs_to :location
                                  # location has_many :restaurants
                                  # restaurant has_and_belongs_to_many :recipes
                                  # restaurant has_and_belongs_to_many :photos
      t.integer :remote_id
      
    end

    add_index :restaurants, :name, :unique => false
    add_index :restaurants, :remote_id, :unique => true

    create_table :meals_restaurants, :id => false do |t|
      t.integer :restaurant_id
      t.integer :meal_id
    end

    create_table :recipes_restaurants, :id => false do |t|
      t.integer :restaurant_id
      t.integer :recipe_id
    end

    create_table :restaurants_tags, :id => false do |t|
      t.integer :restaurant_id
      t.integer :tag_id
    end

    create_table :favourite_restaurants do |t|
      t.integer :restaurant_id  # favourite_restaurant belongs_to :restaurant
                                # restaurant has_many :favourite_restaurant
      t.integer :user_id        # favourite_restaurant belongs_to :user
                                # user has_many :favourite_restaurants
      t.integer :rating         # the rating the user gives the restaurant. (aggregated to compute restaurant's average rating.)
    end

    create_table :retailers do |t|
      t.string   :name, :null => false
      t.text     :description
      t.integer  :location_id    # retailer belongs_to :location
                                 # location has_many :retailers
                                 # restaurant has_and_belongs_to_many :recipes
      t.integer :remote_id

    end

    add_index :retailers, :name, :unique => false
    add_index :retailers, :remote_id, :unique => true

    create_table :favourite_retailers do |t|
      t.integer  :retailer_id   # favourite_retailer belongs_to :retailer
                                # retailer has_many :favourite_retailer
      t.integer  :user_id       # favourite_retailer belongs_to :user
                                # user has_many :favourite_retailers
      t.integer  :rating        # the rating the user gives the retailer. (aggregated to compute retailer's average rating.)
    end

    create_table :photos do |t|
      t.string   :name, :null => false
      t.string   :caption
      t.integer  :owner_id      # photo belongs_to :owner, :class_name => 'User'
                                # user has_many :photos.
      t.string   :image_url, :null => false
      t.string   :thumbnail_url, :null => false
      t.text     :description
      t.integer  :remote_id
    end
    add_index :photos, :remote_id, :unique => true

    create_table :ingredients_photos, :id => false do |t|
      t.integer :ingredient_id
      t.integer :photo_id
    end
    
    create_table :ingredients_retailers, :id => false do |t|
      t.integer :ingredient_id
      t.integer :retailer_id
    end
    
    create_table :photos_restaurants, :id => false do |t|
      t.integer :restaurant_id
      t.integer :photo_id
    end

    create_table :photos_recipes, :id => false do |t|
      t.integer :recipe_id
      t.integer :photo_id
    end

    create_table :photos_retailers, :id => false do |t|
      t.integer :retailer_id
      t.integer :photo_id
    end

    create_table :retailers_tags, :id => false do |t|
      t.integer :retailer_id
      t.integer :tag_id
    end

    create_table :preferences do |t|
      t.string :name, :null => false
      t.string :value
      t.integer :user_id  # preference belongs_to :user
                          # user has_many :preferences
    end

    add_index :preferences, :name, :unique => false

  end

  def self.down
  	drop_table :retailers_tags
  	drop_table :quantities
  	drop_table :locations
  	drop_table :restaurants
  	drop_table :recipes_restaurants
  	drop_table :restaurants_meals
  	drop_table :recipes_restaurants
  	drop_table :restaurants_tags
  	drop_table :favourite_restaurants
  	drop_table :retailers
  	drop_table :retailers_tags
  	drop_table :favourite_retailers
  	drop_table :ingredients_photos
  	drop_table :ingredients_retailers
  	drop_table :photos
  	drop_table :photos_restaurants
  	drop_table :photos_recipes
  	drop_table :photos_retailers
  	drop_table :users
  	drop_table :recipes_tags
  	drop_table :meals_tags
  	drop_table :tags_users
  	drop_table :favourite_recipes
  	drop_table :ingredients_recipes
  	drop_table :ingredients_tags
  	drop_table :recipes
		drop_table :unit_types
  	drop_table :allowed_units
  end
end
