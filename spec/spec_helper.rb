# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'capybara/rails'
require 'capybara/dsl'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require 'shoulda'
require 'authlogic/test_case'
include Authlogic::TestCase
activate_authlogic

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = Rails.root.join('/spec/fixtures/')
  config.include(Capybara, :type => :integration)
end
