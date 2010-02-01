require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Karma do
   before(:each) do
     stub_karma_server
     @karma = KarmaClient::Karma.new(User.make)
   end
  
   describe "#total" do
     it "should return the total karma for that user" do
       @karma.total.should == 7
     end
   end
   
   describe "#levels" do
     it "should return a levels object" do
       @karma.levels.kind_of?(KarmaClient::Levels).should be_true
     end
   end
  
end