require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

describe Taxon do
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
  end
  
  describe "#create_statistics" do
    before do
      @family = Taxon.find_by_rank(4)
      @genus = Taxon.new(:parent_id => @family.id, :rank => 5, :name => "genusgenus")
      @genus.save!
    end
    it "should create a statistics object via the callback" do
      @genus.statistics.should be_an_instance_of(Statistics)
      @genus.statistics.taxon_id.should == @genus.id
    end
  end
end

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

