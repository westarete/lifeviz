require 'spec_helper'

describe TaxonomyNavigationHelper do
  include TaxonomyNavigationHelper

  describe "#dropdown_options" do
    describe "when given some taxons" do      
      before(:each) do
        @bob = Taxon.create!(:name => 'bob')
        @alice = Taxon.create!(:name => 'alice')
      end
      it "should return the html options, with an \"Any\" option prepended" do
        dropdown_options([@bob, @alice]).should == 
          "<option value=\"\">Any</option>\n" +
          "<option value=\"#{@bob.id}\">bob</option>\n" +
          "<option value=\"#{@alice.id}\">alice</option>"
      end
    end
    describe "when given no arguments" do
      it "should return a single html option for \"Any\"" do
        dropdown_options.should == "<option value=\"\">Any</option>"
      end
    end
  end
  
end
