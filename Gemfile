# The Gemfile for the Open Recipe API Server.
source "https://rubygems.org"

gem 'sinatra'
gem 'haml'
gem 'omniauth-facebook', '1.4.0'  # see http://stackoverflow.com/questions/11597130/omniauth-facebook-keeps-reporting-invalid-credentials
gem 'data_mapper'

group :development do
	gem 'sqlite3'
  gem 'dm-sqlite-adapter'
  gem 'rack-test'
	gem 'ruby-debug19'
end

group :test do
	gem 'sqlite3'
  gem 'dm-sqlite-adapter'
  gem 'rack-test'
	gem 'ruby-debug19'
end

group :production do
  gem "pg"
  gem 'dm-postgres-adapter'
#	gem 'aws-s3'
end
