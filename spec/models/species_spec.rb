require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Species do
  fixtures :taxa
  
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
    Taxon.rebuild_lineages!
  end
  
  describe "#validate" do
    before(:each) do
      @parent = Taxon.find(5)
      @taxon = Species.new(:name => "Genus 2", :rank => 5, :parent_id => @parent.id)
      @taxon.valid?
    end
    it "should ensure rank of parent is at the genus level" do
      @taxon.errors[:base].should == "Species need to belong to a genus"
    end
  end
end