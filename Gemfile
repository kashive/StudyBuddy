source 'http://rubygems.org'

gem 'rails', '3.2.13'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'sass'
gem 'devise'
gem 'omniauth-facebook', '1.4.0'
gem 'public_activity'
gem 'kaminari'
gem 'faye'
gem 'thin'
gem 'eventmachine'
gem 'newrelic_rpm'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails'
  gem 'therubyracer'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'twitter-bootstrap-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'nokogiri'
gem "mechanize", "~> 2.7.2"
gem 'gon'
gem "rspec-rails", :group => [:test, :development]
gem "koala"
group :development, :test do
	gem 'sqlite3' 
	gem 'pry' #command line interactive debugger as well as an interative online shell
	gem 'better_errors' #makes the exception page pretty and adds interactive debugging tool
	gem 'binding_of_caller'
	gem 'meta_request'
	gem 'debugger'
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem "capybara"
  gem "guard-rspec"
end
group :production do
  gem 'rails_12factor', '0.0.2'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
