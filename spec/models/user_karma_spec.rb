require File.dirname(__FILE__) + '/../spec_helper'

describe UserKarma do
  before(:each) do
    @user = User.make
  end
  
  describe "#escape" do
    it "should remove unwanted characters" do
      @user.escape('bob@example.com').should == 'bobexamplecom'
    end
    it "should convert to lowercase" do
      @user.escape('HowDY').should == 'howdy'
    end
    it "should collapse extra separators" do
      @user.escape('hi---there').should == 'hi-there'
    end
    it "should remove leading and trailing separators" do
      @user.escape('--howdy--').should == 'howdy'
    end
  end
  
  describe "#permalink" do
    before(:each) do
      @user = User.make(:email => 'bob@example.com')
    end
    it "should return an escaped version of the email" do
      @user.permalink.should == 'bobexamplecom'
    end
    it "should not modify the email string during the conversion process" do
      @user.permalink
      @user.email.should == 'bob@example.com'
    end
  end
  
  describe "#karma_url" do
    it "should return the path to the user's karma resource" do
      @user.karma_url.should =~ /\/karma.json$/
    end
  end
  
  describe "#karma" do
    before(:each) do
      # A sample json response from the karma server.
      json = '{"buckets":{"animals":{"total":-4,"adjustments_path":"/users/ieva/buckets/animals/adjustments.json","bucket_path":"/buckets/animals.json"},"plants":{"total":3,"adjustments_path":"/users/ieva/buckets/plants/adjustments.json","bucket_path":"/buckets/plants.json"}},"total":-1,"user_path":"/users/ieva.json","user":"ieva"}'
      # A RestClient Resource that returns json in response to a get request.
      resource = stub('resource', :get => json)
      # Stub the RestClient Resource to use our objects instead of querying the server.
      RestClient::Resource.stub!(:new => resource)
    end
    it "should fetch and parse the results from the karma server" do
      @user.karma.should == -1
    end
  end
  
  describe "#bronze?" do
    it "should return false if the user has karma of 4 or less" do
      @user.stub!(:karma).and_return(4)
      @user.bronze?.should be_false
    end
    it "should return true if the user has karma of 5 or more" do
      @user.stub!(:karma).and_return(5)
      @user.bronze?.should be_true
    end
  end

  describe "#silver?" do
    it "should return false if the user has karma of 9 or less" do
      @user.stub!(:karma).and_return(9)
      @user.silver?.should be_false
    end
    it "should return true if the user has karma of 10 or more" do
      @user.stub!(:karma).and_return(10)
      @user.silver?.should be_true
    end
  end

  describe "#gold?" do
    it "should return false if the user has karma of 19 or less" do
      @user.stub!(:karma).and_return(19)
      @user.gold?.should be_false
    end
    it "should return true if the user has karma of 20 or more" do
      @user.stub!(:karma).and_return(20)
      @user.gold?.should be_true
    end
  end
  
end