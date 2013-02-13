# The Gemfile for the Open Recipe API Server.
source "https://rubygems.org"

gem 'sinatra'
gem 'sinatra-r18n'
gem 'haml'
gem 'koala'
gem 'activerecord'
gem "rake"
gem 'unicode'
gem 'ruby-units'
gem 'unicode_utils'
gem 'rabl'
gem 'oj' # add either `oj` or `yajl-ruby` as the JSON parser
gem 'tactful_tokenizer'

group :development do
	gem 'sqlite3'
	gem 'ruby-debug19'
  gem 'simplecov'
end

group :test do
	gem 'sqlite3'
  gem 'test-unit'
  gem 'rack-test'
	gem 'ruby-debug19'
  gem 'simplecov'
end

group :production do
  gem "pg"
#	gem 'aws-s3'
end
