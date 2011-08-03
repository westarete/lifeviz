require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Karma do
   before(:each) do
     stub_karma_server
     @karma = KarmaClient::Karma.new(User.make)
   end
   
   describe "#initialize" do
     describe "for an unknown user" do
       before(:each) do
         # First we look for the user and can't find it.
         missing_resource = mock('missing resource')
         missing_resource.should_receive(:get).and_raise(RestClient::ResourceNotFound)
         RestClient::Resource.should_receive(:new).with("http://#{KARMA_SERVER_HOSTNAME}/users/bobexamplecom/karma.json", "", KARMA_API_KEY).and_return(missing_resource)
         
         # Then we try to create the user.
         create_resource = mock('create resource')
         create_resource.should_receive(:put).with('')
         RestClient::Resource.should_receive(:new).with("http://#{KARMA_SERVER_HOSTNAME}/users/bobexamplecom.json", "", KARMA_API_KEY).and_return(create_resource)

         # And then we try to find the user again, and are successful.
         found_resource = mock('found resource')
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
         found_resource.should_receive(:get).and_return(json)
         RestClient::Resource.should_receive(:new).with("http://#{KARMA_SERVER_HOSTNAME}/users/bobexamplecom/karma.json", "", KARMA_API_KEY).and_return(found_resource)
       end
       it "should create the user automatically" do
         @karma = KarmaClient::Karma.new(User.make(:email => 'bob@example.com'))
       end
     end
   end
  
   describe "#total" do
     it "should return the total karma for that user" do
       @karma.total.should == 7
     end
   end
   
  
end