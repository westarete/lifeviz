require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Buckets do
  before(:each) do
    @buckets = KarmaClient::Buckets.new(:plants => 3, :animals => 2)
  end

  it "should define an accessor method for each bucket name" do
    @buckets.should respond_to(:plants)
    @buckets.should respond_to(:animals)
  end
  
  describe "getter methods" do
    it "should return the value of that bucket" do
      @buckets.plants.should == 3
    end
  end
  
  describe "setter methods" do
    it "should set the value of that bucket" do
      @buckets.plants += 2
      @buckets.plants.should == 5
    end
  end
  
end