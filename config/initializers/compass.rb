require 'compass'
Compass.add_project_configuration(Rails.root.join("config", "compass.config"))
Compass.configuration.environment = Rails.env.to_sym
Compass.configure_sass_plugin!
