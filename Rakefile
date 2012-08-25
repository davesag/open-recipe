require 'data_mapper'
require 'rake/testtask'

raise "No models folder found." unless File.directory? './models'
Dir.glob("./models/**.rb").sort.each { |m| require m }

task :default => :test

namespace :db do
  desc "Reset the database."
  task :reset do
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, (ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"))
    DataMapper.finalize
    DataMapper.auto_upgrade!
    puts "Database Established."
  end

  desc "Populates dummy data to the database"
  task(:seed => :reset) do
    seed_file = File.join('db', "#{ENV['RACK_ENV'] || 'development'}_seeds.rb")
    if File.exists?(seed_file)
      load(seed_file)
    else
      seed_file = File.join('db', 'seeds.rb')
      if File.exists?(seed_file)
        load(seed_file)
      else
        puts "WARNING -- NO DATABASE SEED DATA FOUND."
      end
    end
  end
end

desc "run the tests"
task(:test => 'db:reset') do
  puts "Tests running in environment '#{ENV['RACK_ENV']}'"
  Rake::TestTask.new do |t|
    t.libs << "./test"
    t.test_files = FileList['./test/*_test.rb']
    t.verbose = false
  end
end
