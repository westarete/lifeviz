require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.make
  end
  
  describe "#karma_permalink" do
    before(:each) do
      @user = User.make(:email => 'bob@example.com')
    end
    it "should return an escaped version of the email address" do
      @user.karma_permalink.should == 'bobexamplecom'
    end
  end
end