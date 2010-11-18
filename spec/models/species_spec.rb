require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Species do
   it { should have_many :birth_weights }
  
  make_biological_classification(5)
  
  let (:species) { Species.make }
  
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
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
end

# == Schema Information
#
# Table name: taxa
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  parent_id        :integer
#  lft              :integer
#  rgt              :integer
#  rank             :integer
#  lineage_ids      :string(255)
#  avg_adult_weight :float
#  avg_birth_weight :float
#  avg_lifespan     :float
#  avg_litter_size  :float
#

