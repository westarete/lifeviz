require 'spec_helper'

describe SpeciesHelper do
  include SpeciesHelper
  
  let (:species) { Species.make }
  
  describe "#lifespan_with_units" do
    subject { lifespan_with_units(species) }
    context "when there are a few lifespans and the units are the same" do
      before do
        species.lifespans.build(:value => 1, :units => "Days")
        species.lifespans.build(:value => 2, :units => "Days")
        species.lifespans.build(:value => 3, :units => "Days")
      end
      it "should use the same unit" do
        subject.should == "2.00 Days"
      end
    end
    context "when there are a few lifespans with different units" do
      before do
        species.lifespans.build(:value => 30,:units => "Days")
        species.lifespans.build(:value => 1, :units => "Months")
        species.lifespans.build(:value => 2, :units => "Months")
      end
      it "should pick the most common unit" do
        subject.should == "1.33 Months"
      end
    end
    context "when there are a few lifespans with all different units" do
      before do
        species.lifespans.build(:value => 365, :units => "Days")
        species.lifespans.build(:value => 12,  :units => "Months")
        species.lifespans.build(:value => 1,   :units => "Years")
      end
      it "should pick the smallest available units" do
         subject.should == "363.33 Days"
      end
    end
    context "when there are no lifespans" do
      it { should == "N/A" }
    end
  end
  
  describe "#birth_weight_with_units" do
    subject { birth_weight_with_units(species) }
    context "when there are a few birth_weights and the units are the same" do
      before do
        species.birth_weights.build(:value => 1, :units => "Grams")
        species.birth_weights.build(:value => 2, :units => "Grams")
        species.birth_weights.build(:value => 3, :units => "Grams")
      end
      it "should use the same unit" do
        subject.should == "2.00 Grams"
      end
    end
    context "when there are a few birth_weights with different units" do
      before do
        species.birth_weights.build(:value => 500, :units => "Grams")
        species.birth_weights.build(:value => 1,   :units => "Kilograms")
        species.birth_weights.build(:value => 1.5, :units => "Kilograms")
      end
      it "should pick the most common unit" do
        subject.should == "1.00 Kilograms"
      end
    end
    context "when there are no birth_weights" do
      it { should == "N/A" }
    end
  end
  
  describe "#adult_weight_with_units" do
    subject { adult_weight_with_units(species) }
    context "when there are a few adult_weights and the units are the same" do
      before do
        species.adult_weights.build(:value => 1, :units => "Grams")
        species.adult_weights.build(:value => 2, :units => "Grams")
        species.adult_weights.build(:value => 3, :units => "Grams")
      end
      it "should use the same unit" do
        subject.should == "2.00 Grams"
      end
    end
    context "when there are a few adult_weights with different units" do
      before do
        species.adult_weights.build(:value => 500, :units => "Grams")
        species.adult_weights.build(:value => 1,   :units => "Kilograms")
        species.adult_weights.build(:value => 1.5, :units => "Kilograms")
      end
      it "should pick the most common unit" do
        subject.should == "1.00 Kilograms"
      end
    end
    context "when there are no adult_weights" do
      it { should == "N/A" }
    end
  end
  
  describe "#litter_size" do
    subject { litter_size(species) }
    context "when there are a few litter sizes" do
      before do
        species.litter_sizes.build(:measure => 1)
        species.litter_sizes.build(:measure => 2)
        species.litter_sizes.build(:measure => 3)
      end
      it "should return the average litter size formatted properly" do
        subject.should == "2.0"
      end
    end
    context "when there are no litter sizes" do
      it { should == "N/A" }
    end
  end
  
end