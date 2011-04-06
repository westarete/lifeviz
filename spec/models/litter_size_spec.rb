require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

describe LitterSize do
  
  before(:each) do
    @species = Species.make
    @litter_size = @species.litter_sizes.new
  end

  it { should belong_to(:species)               }
  it { should validate_presence_of(:species_id) }
  it { should validate_presence_of(:value)    }
  
  describe "after_save" do
    context "when saving a new litter size" do
      before do
        make_statistics_set
        LitterSize.create!(:value => 30, :species_id => @species1.id)
      end
      it "should recalculate the litter size stats" do
        @species1.statistics[:minimum_litter_size].should == 10.0
        @species1.statistics[:maximum_litter_size].should == 30.0
        @species1.statistics[:average_litter_size].should == 20.0
        @species1.statistics[:standard_deviation_litter_size].should be_close(8.340, 0.001)
      end
    end
  end
  
end


# == Schema Information
#
# Table name: litter_sizes
#
#  id              :integer         not null, primary key
#  species_id      :integer         not null
#  value           :decimal(, )     not null
#  created_at      :datetime
#  updated_at      :datetime
#  created_by      :integer
#  created_by_name :string(255)
#

