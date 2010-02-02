require 'capistrano/ext/multistage'     # Support for multiple deploy targets
require 'capistrano-helpers/passenger'  # Support for Apache passenger
require 'capistrano-helpers/git'        # Efficient git setup
require 'capistrano-helpers/branch'     # Ask what branch to deploy
require 'capistrano-helpers/shared'     # Symlink shared files after deploying
require 'capistrano-helpers/gems'       # Install all required rubygems
require 'capistrano-helpers/migrations' # Run all migrations automatically
require 'capistrano-helpers/campfire'   # Post deploy info to campfire
require 'hoptoad_notifier/capistrano'   # Hoptoad notification

# The name of the application.
set :application, "anage"

# Location of the source code.
set :repository,  "git@github.com:westarete/anage.git"

# Set the files that should be symlinked to their shared counterparts.
set :shared, %w{ 
  config/database.yml 
  config/initializers/session_store.rb
}
