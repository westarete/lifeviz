require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Statistics do
  
  describe "#average_lifespan" do
    subject { @species1.statistics.average_lifespan }
    before do
      make_statistics_set
    end
    context "when the average_lifespan is nil" do
      before { @species1.statistics.average_lifespan = nil }
      it { should == nil }
    end
    context "when the average_lifespan is 15 days" do
      before { @species1.statistics.average_lifespan = 15 }
      it { should == "15.00 days" }
    end
    context "when the average_lifespan is 100 days" do
      before { @species1.statistics.average_lifespan = 100 }
      it { should == "3.33 months" }
    end
    context "when the average_lifespan is over 9000 days" do
      before { @species1.statistics.average_lifespan = 9000 }
      it { should == "24.66 years" }
    end
    context "when the average_lifespan is 2200000 days" do
      before { @species1.statistics.average_lifespan = 2200000 }
      it { should == "6,027.40 years" }
    end
  end
  
  describe "#average_adult_weight" do
    subject { @species1.statistics.average_adult_weight }
    before do
      make_statistics_set
    end
    context "when the average_adult_weight is nil" do
      before { @species1.statistics.average_adult_weight = nil }
      it { should == nil }
    end
    context "when the average_adult_weight is 15 grams" do
      before { @species1.statistics.average_adult_weight = 15 }
      it { should == "15.00 grams" }
    end
    context "when the average_adult_weight is 2200 grams" do
      before { @species1.statistics.average_adult_weight = 2200 }
      it { should == "2.20 kilograms" }
    end
    context "when the average_adult_weight is 2200000 grams" do
      before { @species1.statistics.average_adult_weight = 2200000 }
      it { should == "2,200.00 kilograms" }
    end
  end
  
  describe "#calculate_lifespan" do
    before { make_statistics_set }
    context "for a given species' annotations" do
      before do
        @species1.statistics.calculate_statistics
      end
      it "calculates statistics" do
        @species1.statistics.minimum_lifespan.should == "10.00 days"
        @species1.statistics.maximum_lifespan.should == "20.00 days"
        @species1.statistics.average_lifespan.should == "15.00 days"
        @species1.statistics.standard_deviation_lifespan.should == "5.16 days"
        @species1.statistics.minimum_birth_weight.should == "10.00 grams"
        @species1.statistics.maximum_birth_weight.should == "20.00 grams"
        @species1.statistics.average_birth_weight.should == "15.00 grams"
        @species1.statistics.standard_deviation_birth_weight.should == "5.16 grams"
        @species1.statistics.minimum_adult_weight.should == "10.00 grams"
        @species1.statistics.maximum_adult_weight.should == "20.00 grams"
        @species1.statistics.average_adult_weight.should == "15.00 grams"
        @species1.statistics.standard_deviation_adult_weight.should == "5.16 grams"
        @species1.statistics.minimum_litter_size.should == "10.00"
        @species1.statistics.maximum_litter_size.should == "20.00"
        @species1.statistics.average_litter_size.should == "15.00"
        @species1.statistics.standard_deviation_litter_size.should == "5.16"
      end
    end
    context "for a given taxon's species lifespans" do
      before do
        make_statistics_set
        @taxon.statistics.calculate_statistics
      end
      it "calculates statistics" do
        @taxon.statistics.minimum_lifespan.should == "10.00 days"
        @taxon.statistics.maximum_lifespan.should == "40.00 days"
        @taxon.statistics.average_lifespan.should == "25.00 days"
        @taxon.statistics.standard_deviation_lifespan.should == "11.36 days"
        @taxon.statistics.minimum_birth_weight.should == "10.00 grams"
        @taxon.statistics.maximum_birth_weight.should == "40.00 grams"
        @taxon.statistics.average_birth_weight.should == "25.00 grams"
        @taxon.statistics.standard_deviation_birth_weight.should == "11.36 grams"
        @taxon.statistics.minimum_adult_weight.should == "10.00 grams"
        @taxon.statistics.maximum_adult_weight.should == "40.00 grams"
        @taxon.statistics.average_adult_weight.should == "25.00 grams"
        @taxon.statistics.standard_deviation_adult_weight.should == "11.36 grams"
        @taxon.statistics.minimum_litter_size.should == "10.00"
        @taxon.statistics.maximum_litter_size.should == "40.00"
        @taxon.statistics.average_litter_size.should == "25.00"
        @taxon.statistics.standard_deviation_litter_size.should == "11.36"
      end
    end
  end
  
end

# == Schema Information
#
# Table name: statistics
#
#  id                              :integer         not null, primary key
#  taxon_id                        :integer
#  minimum_lifespan                :float
#  minimum_adult_weight            :float
#  minimum_litter_size             :float
#  minimum_birth_weight            :float
#  maximum_lifespan                :float
#  maximum_adult_weight            :float
#  maximum_litter_size             :float
#  maximum_birth_weight            :float
#  average_lifespan                :float
#  average_adult_weight            :float
#  average_litter_size             :float
#  average_birth_weight            :float
#  standard_deviation_lifespan     :float
#  standard_deviation_adult_weight :float
#  standard_deviation_litter_size  :float
#  standard_deviation_birth_weight :float
#  created_at                      :datetime
#  updated_at                      :datetime
#

