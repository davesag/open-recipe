require 'bundler/setup'
require 'active_record'
require 'active_support/all'  # added for Time.zone support below
require 'rake/testtask'

raise "No models folder found." unless File.directory? './models'
Dir.glob("./models/**.rb").sort.each { |m| require m }

task :default => :test

namespace :db do
  desc "Set up the connection to the database"
  task :environment do
    dbconfig = YAML.load(File.read('./config/database.yml'))

    # in showpony.rb we configure for test, development and production only right now.
    # and no matter what you sepcify, the tests are always run against the test database
    # so be sure to seed all the databases before running this
    # %> RACK_ENV=test rake db:seed
    # %> RACK_ENV=development rake db:seed
    # %> RACK_ENV=production rake db:seed
    # Note also that, when pushed to Heroku, the databases will switch to PostGRES
    ActiveRecord::Base.establish_connection dbconfig[ENV['RACK_ENV']||'development']
    Time.zone = 'UTC'
    ActiveRecord::Base.time_zone_aware_attributes = true
    ActiveRecord::Base.default_timezone = :utc
  end

  desc "Migrate the database by walking through the migrations in db/migrate"
  task(:migrate => :environment) do
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

desc "run the tests"
task(:test => 'db:environment') do
  puts "Tests running in environment '#{ENV['RACK_ENV']}'"
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['./test/*_test.rb']
    t.verbose = false
  end
end
