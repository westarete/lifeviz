require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before(:each) do
    @user = User.make
  end
  
  it "should include the karma client" do
    User.included_modules.should include(KarmaClient::User)
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
# == Schema Information
#
# Table name: users
#
#  id                :integer         not null, primary key
#  email             :string(255)
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)     not null
#  created_at        :datetime
#  updated_at        :datetime
#  openid_identifier :string(255)
#

