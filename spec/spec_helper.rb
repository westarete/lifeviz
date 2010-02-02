# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

# Use machinist blueprints.
require File.expand_path(File.dirname(__FILE__) + "/blueprints")

# Use shoulda matchers
require 'shoulda'

# Get AuthLogic running.
require 'authlogic/test_case'
include Authlogic::TestCase
activate_authlogic

# Stub out the actual karma server so it's talking to our fake data instead.
def stub_karma_server(json=nil)
  # A sample json response from the karma server.
  json ||= %{
    {
      "total":7,
      "user_path":"/users/bobexamplecom.json",
      "user":"bobexamplecom",
      "buckets": {
        "animals": {
          "total":4,
          "adjustments_path":"/users/bobexamplecom/buckets/animals/adjustments.json",
          "bucket_path":"/buckets/animals.json"
         },
         "plants": {
           "total":3,
           "adjustments_path":"/users/bobexamplecom/buckets/plants/adjustments.json",
           "bucket_path":"/buckets/plants.json"
         }
       }
     }
  }
  # A RestClient Resource that returns json in response to a get request, and
  # accepts a post request.
  resource = stub('resource', :get => json, :post => nil, :put => nil)
  # Stub the RestClient Resource to use our objects instead of querying the server.
  RestClient::Resource.stub!(:new => resource)
end

