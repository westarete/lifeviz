require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Taxon do
  fixtures :taxa
  
  describe "#rebuild_lineage" do
    before(:each) do
      Taxon.rebuild!
      @family = Taxon.find(6)
      @taxon = Taxon.new(:name => "Genus 2", :rank => 5)
      @taxon.save!
      @taxon.move_to_child_of(@family)
      # Set lft and rgt values for every taxon. Necessary!
    end
    it "should set lineage_ids to the correct values" do
      @taxon.rebuild_lineage
      @taxon.lineage_ids.should == "1,2,3,4,5,6"
    end
  end
  
end