source 'http://rubygems.org'

# Web framework.
gem 'rails', '2.3.10'
gem 'activesupport', '2.3.10'

# View design.
gem 'haml', '3.0.22'
gem 'compass', '0.10.5'

# Database.
gem 'pg', '0.9.0'

# Show text-based progress bar for long-running console tasks.
gem 'progressbar', '0.9.0'

# Nested sets for storing hierarchies.
gem 'awesome_nested_set', '1.4.3'

# Authentication
gem 'rack-openid', '1.2.0'
gem 'authlogic', '2.1.6'
gem 'authlogic-oid', '1.0.4'

# Unit conversion library
gem 'quantity', '0.1.1'

# Pagination
gem 'will_paginate', '2.3.11'

# For seeding database.
gem 'hpricot', '0.8.2'
gem 'fastercsv', '1.5.4'

# Null object pattern.
gem 'activerecord_null_object', '0.2.0'

# Talk to karma server.
gem 'rest-client', '1.3.0', :require => "restclient"

# Hoptoad notifier
gem 'hoptoad_notifier', '2.3.10'

# Analyze performance (visit http://localhost:3000/newrelic)
gem 'newrelic_rpm', '2.13.2'

group :development do
  # Faster development server
  gem 'unicorn', '1.1.4'

  # debugger
  gem 'ruby-debug', '0.10.3'

  # Deployment.
  gem 'capistrano', '2.5.19'
  gem 'capistrano-helpers', '0.6.2'
  gem 'capistrano-ext', '1.2.1'
end

group :development, :test do
  # Our test gems have to exist in both groups!
  gem 'rspec', '= 1.3.0'
  gem 'rspec-rails', '= 1.3.2'

  # Automatically run tests.
  gem 'ZenTest', '4.4.0'
  gem 'autotest-rails', '4.1.0'
  
  # Test gems, and testing helpers.
  gem 'mocha', '0.9.8'

  # Create dummy data for tests.
  gem 'machinist', '1.0.6'
  gem 'faker', '0.3.1'

  # Integration testing engine.
  gem 'capybara', '0.3.9'
  gem 'capybara-envjs', '0.1.6'

  # RSpec matchers.
  gem 'shoulda', '2.11.3'
  
  # Cache API calls for stubbing.
  gem 'ephemeral_response', '0.3.2'

  # Run multiple tests at the same time.
  gem 'specjour', '0.2.5'
  
  # Needed by capybara to show pages.
  gem 'launchy', '0.3.7'
end
