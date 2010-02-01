require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::User do
  before(:each) do
    stub_karma_server
    @user = User.make
  end
  
  describe "#karma" do
    it "should be mixed in to the user model" do
      @user.respond_to?(:karma).should be_true
    end
    it "should return a karma object" do
      @user.karma.kind_of?(KarmaClient::Karma).should be_true
    end
  end

end