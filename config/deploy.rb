
require 'capistrano/ext/multistage'    # Support for multiple deploy targets
require 'capistrano-helpers/passenger' # Support for Apache passenger
require 'capistrano-helpers/specs'     # Check specs before deploying
require 'capistrano-helpers/features'  # Check cucumber features before deploying
require 'capistrano-helpers/preflight' # Run preflight checklist before deploying
require 'capistrano-helpers/privates'  # Symlink private files after deploying
require 'capistrano-helpers/version'   # Record the version number after deploying
require 'capistrano-helpers/campfire'  # Post deploy info to campfire

# The name of the application.
set :application, "anage"

# The source code management software to use.
set :scm, "git"

# Location of the source code.
set :repository,  "git@github.com:westarete/anage.git"

# Non-standard ssh port.
ssh_options[:port] = 22222

# Set the files that should be replaced with their private counterparts.
set :privates, %w{ config/database.yml config/session_secret.txt }
