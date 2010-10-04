require File.dirname(__FILE__) + '/../../spec_helper'

describe KarmaClient::Tags do
  before(:each) do
    @tags = KarmaClient::Tags.new({
      'plants' => {
        'total' => 3,
        'adjustments_path' => '/users/bobexamplecom/tags/plants/adjustments.json',
      },
      'animals' => {
        'total' => 2,
        'adjustments_path' => '/users/bobexamplecom/tags/animals/adjustments.json',
      },
    })
  end

  it "should define an accessor method for each tag name" do
    @tags.should respond_to(:plants)
    @tags.should respond_to(:animals)
  end
  
  describe "#_total" do
    it "should return the total of all tags" do
      @tags._total.should == 5
    end
  end
  
  describe "getter methods" do
    it "should return the value of that tag" do
      @tags.plants.should == 3
    end
  end
  
  describe "setter methods" do
    before(:each) do
      stub_karma_server
    end
    it "should set the value of that tag" do
      @tags.plants += 2
      @tags.plants.should == 5
    end
    it "should send the changes back to the karma server" do
      resource = mock('resource')
      resource.should_receive(:post).with('adjustment[value]=3')
      RestClient::Resource.should_receive(:new).with("http://#{KARMA_SERVER_HOSTNAME}/users/bobexamplecom/tags/plants/adjustments.json", "", KARMA_API_KEY).and_return(resource)
      @tags.plants += 3
    end
  end
  
end