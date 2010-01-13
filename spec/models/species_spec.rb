# == Schema Information
#
# Table name: taxa
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  rank        :integer
#  lineage_ids :string(255)
#

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
      @taxon.errors[:base].should == "Species needs to belong to a genus"
    end
  end
end
