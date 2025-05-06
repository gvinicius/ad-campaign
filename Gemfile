# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.3.1'

# Web framework
gem 'puma', '~> 6.3'
gem 'rack', '~> 2.2'
gem 'sinatra', '~> 3.0'
gem 'sinatra-contrib', '~> 3.0'

# ORM and Models
gem 'dry-schema', '~> 1.13'
gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'
gem 'dry-validation', '~> 1.10'
gem 'sqlite3', '~> 1.6'

# Utilities
gem 'chronic', '~> 0.10.2' # For time parsing
gem 'dotenv', '~> 2.8'
gem 'json', '~> 2.6'
gem 'rake', '~> 13.0'
gem 'rufus-scheduler', '~> 3.9' # For scheduled tasks

group :development do
  gem 'pry', '~> 0.14'
  gem 'shotgun', '~> 0.9'
end

group :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.12'
end

# Code quality
gem 'rubocop', '~> 1.75'
