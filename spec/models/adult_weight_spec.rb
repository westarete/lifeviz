require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# make sure we have biological classification before we create species
make_biological_classification(5)

describe AdultWeight do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:adult_weight)  { species.adult_weights.new }
  
  before do
    species
    adult_weight
  end

  it { should belong_to(:species)                   }
  it { should validate_presence_of :species_id      }
  it { should validate_presence_of(:value_in_grams) }
  
  describe "#value" do
    subject { adult_weight.value }
    before(:each) do
      adult_weight.value_in_grams = 1000
    end
    
    context "when units is Grams" do
      before { adult_weight.units = "Grams" }
      it { should == 1000 }
    end
    
    context "when units is Kilograms" do
      before { adult_weight.units = "Kilograms" }
      it { should == 1 }
    end
  end
  
  describe "#value=" do
    context "when units is not set" do
      before(:each) do
        adult_weight.units = nil
        adult_weight.value = 1000
      end
      it "should return itself" do
        adult_weight.value.should == 1000
      end
      it "should not set value_in_grams" do
        adult_weight.value_in_grams.should be_nil
      end
    end
    context "when units is set" do
      before(:each) do
        adult_weight.value = 1000
      end
      it "should return itself in #value" do
        adult_weight.value.should == 1000
      end
      context "to grams" do
        before(:each) do
          adult_weight.units = "Grams"
        end
        it "should set value correctly" do
          adult_weight.value.should == 1000
        end
      end
      context "to kilograms" do
        before(:each) do
          adult_weight.units = "Kilograms"
        end
        it "should set value correctly" do
          adult_weight.value.should == 1000
        end
      end
    end
  end
  
  describe "#in_units" do
    before(:each) do
      adult_weight.value_in_grams = 1000
    end
    describe "with grams" do
      it "should return the value in grams" do
        adult_weight.in_units("Grams").should == 1000
      end
    end
    describe "with Kilograms" do
      it "should return the value in kilograms" do
        adult_weight.in_units("Kilograms").should == 1
      end
    end
  end
  
  describe "#to_s" do      
    before(:each) do
      adult_weight.value_in_grams = 2000
    end
    describe "when units is not set" do
      before(:each) do
        adult_weight.units = nil
      end
      it "should return an empty string" do
        adult_weight.to_s.should == ""
      end
    end
    describe "when units is set" do
      before(:each) do
        adult_weight.units = "Kilograms"
      end
      it { adult_weight.to_s.should == "2 kilograms" }
    end
  end
  
end



# == Schema Information
#
# Table name: adult_weights
#
#  id               :integer         not null, primary key
#  species_id       :integer         not null
#  value_in_grams   :decimal(, )     not null
#  created_at       :datetime
#  updated_at       :datetime
#  units            :string(255)
#  created_by       :integer
#  created_by_name  :string(255)
#  citation         :string(255)
#  citation_context :text
#

