require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Buckets do
  before(:each) do
    @buckets = KarmaClient::Buckets.new({
      'plants' => {
        'total' => 3,
        'adjustments_path' => '/users/bobexamplecom/buckets/plants/adjustments.json',
      },
      'animals' => {
        'total' => 2,
        'adjustments_path' => '/users/bobexamplecom/buckets/animals/adjustments.json',
      },
    })
  end

  it "should define an accessor method for each bucket name" do
    @buckets.should respond_to(:plants)
    @buckets.should respond_to(:animals)
  end
  
  describe "#_total" do
    it "should return the total of all buckets" do
      @buckets._total.should == 5
    end
  end
  
  describe "getter methods" do
    it "should return the value of that bucket" do
      @buckets.plants.should == 3
    end
  end
  
  describe "setter methods" do
    before(:each) do
      stub_karma_server
    end
    it "should set the value of that bucket" do
      @buckets.plants += 2
      @buckets.plants.should == 5
    end
    it "should send the changes back to the karma server" do
      resource = mock('resource')
      resource.should_receive(:post).with('adjustment[value]=3')
      RestClient::Resource.should_receive(:new).with("http://#{KARMA_SERVER_HOSTNAME}/users/bobexamplecom/buckets/plants/adjustments.json").and_return(resource)
      @buckets.plants += 3
    end
  end
  
end