require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Levels do
  
  describe "#bronze?" do
    it "should return false if the total karma is 2 or less" do
      KarmaClient::Levels.new(0).bronze?.should be_false
      KarmaClient::Levels.new(2).bronze?.should be_false
    end
    it "should return true if the total karma is 3 or more" do
      KarmaClient::Levels.new(3).bronze?.should be_true
      KarmaClient::Levels.new(9).bronze?.should be_true
    end
  end

  describe "#silver?" do
    it "should return false if the total karma is 4 or less" do
      KarmaClient::Levels.new(3).silver?.should be_false
      KarmaClient::Levels.new(4).silver?.should be_false
    end
    it "should return true if the total karma is 5 or more" do
      KarmaClient::Levels.new(5).silver?.should be_true
      KarmaClient::Levels.new(9).silver?.should be_true
    end
  end
  
  describe "#gold?" do
    it "should return false if the total karma is 7 or less" do
      KarmaClient::Levels.new(6).gold?.should be_false
      KarmaClient::Levels.new(7).gold?.should be_false
    end
    it "should return true if the total karma is 8 or more" do
      KarmaClient::Levels.new(8).gold?.should be_true
      KarmaClient::Levels.new(9).gold?.should be_true
    end
  end
  
end