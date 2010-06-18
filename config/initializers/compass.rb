require 'compass'
rails_root = (defined?(Rails) ? Rails.root : RAILS_ROOT).to_s
Compass.add_project_configuration(File.join(rails_root, "config", "compass.config"))
Compass.configuration.environment = RAILS_ENV.to_sym
Compass.configure_sass_plugin!
