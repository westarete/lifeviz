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
   it { should have_many :birth_weights }
  
  fixtures :taxa
  
  let (:species) { Species.make }
  
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
    Taxon.rebuild_lineages!
  end
  
  describe "#validate" do
    before do
      @parent = Taxon.find(5)
      @taxon = Species.new(:name => "Genus 2", :rank => 5, :parent_id => @parent.id)
      @taxon.validate
    end
    it "should ensure rank of parent is at the genus level" do
      @taxon.errors[:base].should == "Species needs to belong to a genus"
    end
  end
  
  describe "#lifespan" do
    subject { species.lifespan }
    context "when there are a few lifespans and the units are the same" do
      before do
        species.lifespans.build(:value => 1, :units => "Days")
        species.lifespans.build(:value => 2, :units => "Days")
        species.lifespans.build(:value => 3, :units => "Days")
      end
      it { should == "2.0 Days" }
    end
    context "when there are a few lifespans with different units" do
      before do
        species.lifespans.build(:value => 1,   :units => "Months")
        species.lifespans.build(:value => 1.5, :units => "Months")
        species.lifespans.build(:value => 2,   :units => "Months")
      end
      it { should == "1.5 Months" }
    end
    context "when there are no lifespans" do
      it { should == "N/A" }
    end
  end
end
