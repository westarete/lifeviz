# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Required gems for development

# Analyze performance (visit http://localhost:3000/newrelic)
config.gem 'newrelic_rpm', :version => '2.9.8'

# Deployment recipes.
config.gem 'capistrano-helpers', :lib => false, :version => '0.3.2'

# Behavior-driven development.
config.gem 'rspec',              :lib => false, :version => '1.3.0'
config.gem 'rspec-rails',        :lib => false, :version => '1.3.2'

# Generate fake data.
config.gem 'faker', :version => '0.3.1'

# Replacement for fixtures.
config.gem 'machinist', :version => '1.0.5'

# Provides ActiveRecord matchers that we can use with rspec.
config.gem 'shoulda', :version => '2.10.2'

# Mock browser testing.
config.gem 'webrat', :version => '0.7.0'

# Story driven development.
config.gem 'cucumber', :version => '0.6.2'