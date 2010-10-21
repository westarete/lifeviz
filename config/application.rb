require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Lifeviz
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    
    # Automatically load files in lib folder.
    config.autoload_paths += %W(#{Rails.root}/lib)

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]
  end
end
