# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

require 'capybara/rails'
require 'capybara/dsl'

# Change api key for karma, so we can expect it.
KARMA_API_KEY = 'karmatestapikey'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.include(Capybara, :type => :integration)
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
      "tags": {
        "animals": {
          "total":4,
          "adjustments_path":"/users/bobexamplecom/tags/animals/adjustments.json",
          "tag_path":"/tags/animals.json"
         },
         "plants": {
           "total":3,
           "adjustments_path":"/users/bobexamplecom/tags/plants/adjustments.json",
           "tag_path":"/tags/plants.json"
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

def log_in
  visit root_path
  fill_in 'user_email', :with => user.email
  fill_in 'user_password', :with => "secret"
  click 'Login'
end

def make_biological_classification(rank = 5)
  return false if rank < -1 || 5 < rank
  Taxon.find_by_rank(rank) ? make_biological_classification(rank - 1) : Taxon.create(:rank => rank.to_i, :parent_id => make_biological_classification(rank - 1), :name => Faker::Name.first_name).id
end