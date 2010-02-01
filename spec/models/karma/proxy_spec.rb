require File.dirname(__FILE__) + '/../../spec_helper'

describe Karma::Proxy do
  before(:each) do
    @buckets = { :comments => 1, :edits => 2 }
    @proxy = Karma::Proxy.new(@buckets)
  end
  it "should be a Fixnum" do
    @proxy.kind_of?(Fixnum).should be_true
  end
  it "should be equal to the karma total" do
    @proxy.should == 3
  end
  it "should have a getter for each bucket" do
    @proxy.comments.should == 1
    @proxy.edits.should == 2
  end
  it "should have a setter for each bucket" do
    @proxy.comments += 1
    @proxy.comments.should == 2
    @proxy.edits -= 1
    @proxy.edits.should == 1
  end
  describe "when the buckets are updated" do
    it "should update the total" do
      @proxy.should == 3
      @proxy.comments += 2
      @proxy.should == 5
    end
    it "should keep the bucket values independent of each other" do
      @proxy.comments += 1
      @proxy.comments.should == 2
      @proxy.edits -= 1
      @proxy.edits.should == 1
    end
  end
  describe "for a non-existent bucket" do
    it "should raise a NoMethodError" do
      lambda { @proxy.not_there }.should raise_error(NoMethodError)
    end
  end
end