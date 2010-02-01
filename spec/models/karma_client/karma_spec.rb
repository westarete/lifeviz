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
   
   describe "#total=" do
     it "should update the total" do
       @karma.total = 12
       @karma.total.should == 12
     end
   end
   
   describe "#levels" do
     it "should return a levels object" do
       @karma.levels.kind_of?(KarmaClient::Levels).should be_true
     end
     it "should be initialized with the proper total" do
       @karma.levels.bronze?.should be_true
       @karma.levels.silver?.should be_true
       @karma.levels.gold?.should be_false       
     end
   end
  
end