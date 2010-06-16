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
  
end