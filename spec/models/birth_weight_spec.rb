require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

describe BirthWeight do
  
  before(:each) do
    @species = Species.make
    @birth_weight = @species.birth_weights.new
  end
  
  it { should belong_to :species }
  it { should validate_presence_of :species_id }
  it { should validate_presence_of :value_in_grams }
  
  describe "after_save" do
    context "when saving a new birth weight" do
      before do
        make_statistics_set
        BirthWeight.create!(:value_in_grams => 30, :units => "Grams", :species_id => @species1.id)
      end
      it "should recalculate the birth weight stats" do
        @species1.statistics[:minimum_birth_weight].should == 10.0
        @species1.statistics[:maximum_birth_weight].should == 30.0
        @species1.statistics[:average_birth_weight].should == 20.0
        @species1.statistics[:standard_deviation_birth_weight].should be_close(8.340, 0.001)
      end
    end
  end
  
  describe "#value" do
    subject { @birth_weight.value }
    before(:each) do
      @birth_weight.value_in_grams = 1000
    end
    
    context "when units is Grams" do
      before { @birth_weight.units = "Grams" }
      it { should == 1000 }
    end
    
    context "when units is Kilograms" do
      before { @birth_weight.units = "Kilograms" }
      it { should == 1 }
    end
  end
  
  describe "#value=" do
    context "when units is not set" do
      before(:each) do
        @birth_weight.units = nil
        @birth_weight.value = 1000
      end
      it "should return itself" do
        @birth_weight.value.should == 1000
      end
      it "should not set value_in_grams" do
        @birth_weight.value_in_grams.should be_nil
      end
    end
    context "when units is set" do
      before(:each) do
        @birth_weight.value = 1000
      end
      it "should return itself in #value" do
        @birth_weight.value.should == 1000
      end
      context "to grams" do
        before(:each) do
          @birth_weight.units = "Grams"
        end
        it "should set value correctly" do
          @birth_weight.value.should == 1000
        end
      end
      context "to kilograms" do
        before(:each) do
          @birth_weight.units = "Kilograms"
        end
        it "should set value correctly" do
          @birth_weight.value.should == 1000
        end
      end
    end
  end
  
  describe "#in_units" do
    before(:each) do
      @birth_weight.value_in_grams = 1000
    end
    describe "with grams" do
      it "should return the value in grams" do
        @birth_weight.in_units("Grams").should == 1000
      end
    end
    describe "with Kilograms" do
      it "should return the value in kilograms" do
        @birth_weight.in_units("Kilograms").should == 1
      end
    end
  end
  
  describe "#to_s" do      
    before(:each) do
      @birth_weight.value_in_grams = 2000
    end
    describe "when units is not set" do
      before(:each) do
        @birth_weight.units = nil
      end
      it "should return an empty string" do
        @birth_weight.to_s.should == ""
      end
    end
    describe "when units is set" do
      before(:each) do
        @birth_weight.units = "Kilograms"
      end
      it { @birth_weight.to_s.should == "2.0 kilogram" }
    end
  end
  
end



# == Schema Information
#
# Table name: birth_weights
#
#  id              :integer         not null, primary key
#  species_id      :integer
#  value_in_grams  :decimal(, )
#  units           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  created_by      :integer
#  created_by_name :string(255)
#  citation        :text
#  context         :text
#

