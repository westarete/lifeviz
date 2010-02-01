require File.dirname(__FILE__) + '/../../spec_helper'

describe Karma::BlankSlate do
  before(:each) do
    @blank = BlankSlate.new
  end
  it "should not have an #object_id method" do
    lambda { @blank.object_id }.should raise_error(NoMethodError)
  end
  it "should not have a #class method" do
    lambda { @blank.class }.should raise_error(NoMethodError)
  end
  it "should not have a #methods method" do
    lambda { @blank.methods }.should raise_error(NoMethodError)
  end
  it "should not have a #respond_to? method" do
    lambda { @blank.respond_to?(:id) }.should raise_error(NoMethodError)
  end
  it "should not have a #send method" do
    lambda { @blank.send }.should raise_error(NoMethodError)
  end
  it "should not have a #clone method" do
    lambda { @blank.clone }.should raise_error(NoMethodError)
  end
  it "should not have a #== method" do
    lambda { @blank == 0 }.should raise_error(NoMethodError)
  end
  it "should have an #__id__ method" do
    @blank.__id__.should_not be_nil
  end
  it "should have a #__send__method" do
    @blank.__send__(:__id__).should == @blank.__id__
  end
end
