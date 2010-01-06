require 'spec_helper'

describe TaxonomyNavigationHelper do
  include TaxonomyNavigationHelper

  describe "#options_for_taxonomy_select" do
    describe "when given some taxons" do      
      before(:each) do
        @bob = Taxon.create!(:name => 'bob', :rank => 6)
        @alice = Taxon.create!(:name => 'alice', :rank => 6)
      end
      it "should return the html options, with an \"Any\" option prepended" do
        options_for_taxonomy_select([@bob, @alice]).should == 
          "<option value=\"\">Any</option>\n" +
          "<option value=\"#{@bob.id}\">bob</option>\n" +
          "<option value=\"#{@alice.id}\">alice</option>"
      end
    end
    describe "when given no arguments" do
      it "should return a single html option for \"Any\"" do
        options_for_taxonomy_select.should == "<option value=\"\">Any</option>"
      end
    end
  end
  
end
