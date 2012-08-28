require 'bundler/setup'
require 'active_record'
require 'active_support/all'  # added for Time.zone support below
require 'rake/testtask'

task :default => :test

namespace :db do
  desc "Set up the connection to the database"
  task :environment do
    # %> RACK_ENV=test rake db:seed
    # %> RACK_ENV=development rake db:seed
    # %> RACK_ENV=production rake db:seed
    # Note also that, when pushed to Heroku, the databases will switch to PostGRES
    ActiveRecord::Base.establish_connection (ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db/#{ENV['RACK_ENV'] || 'development'}.sqlite3")
    Time.zone = 'UTC'
    ActiveRecord::Base.time_zone_aware_attributes = true
    ActiveRecord::Base.default_timezone = :utc
  end

  desc "Migrate the database by walking through the migrations in db/migrate"
  task(:migrate => :environment) do
    raise "No models folder found." unless File.directory? './models'
    Dir.glob("./models/**.rb").sort.each { |m| require m }
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("./db/migrate", ENV["VERSION"] ? ENV[VERSION].to_i : nil)
  end
  
  desc 'Load the seed data from db/seeds.rb'
  task(:seed => :migrate) do
    seed_file = File.join('./db', "#{ENV['RACK_ENV'] || 'development'}_seeds.rb")
    if File.exists?(seed_file)
      load(seed_file)
    else
      seed_file = File.join('./db', 'seeds.rb')
      if File.exists?(seed_file)
        load(seed_file)
      else
        puts "WARNING -- NO DATABASE SEED DATA FOUND."
      end
    end
  end

  desc 'Output the schema to db/schema.rb'
  task(:schema => :migrate) do
    File.open('./db/schema.rb', 'w') do |f|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, f)
    end
  end
  
  desc "Initialise the database by loading schema.rb file."
  task(:load => :environment) do
    schema_file = ENV['SCHEMA'] || File.join('./db', 'schema.rb')
    if File.exists?(schema_file)
      load(schema_file)
    else
      puts "WARNING -- NO SCHEME FILE FOUND OR SPECIFIED."
    end
  end
end

desc "run the unit tests"
task(:test => 'db:environment') do
  require 'simplecov'
  puts "Tests running in environment '#{ENV['RACK_ENV']}'"
  SimpleCov.start
  SimpleCov.command_name 'test:units'
  # load all models to save having to do it in the tests themselves.
  raise "No models folder found." unless File.directory? './models'
  Dir.glob("./models/**.rb").sort.each { |m| require m }
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['./test/*_test.rb']
    t.verbose = false
  end
end
