require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Statistics do
  
  describe "calculate_lifespan" do
    context "for a given species' lifespans" do
      before do
        make_statistics_set
        @species1.statistics.calculate_lifespan
      end
      it "should calculate statistics" do
        @species1.statistics.minimum_lifespan.should == 10.0
        @species1.statistics.maximum_lifespan.should == 20.0
        @species1.statistics.average_lifespan.should == 15.0
        @species1.statistics.standard_deviation_lifespan.should be_close(7.071, 0.001)
      end
    end
    context "for a given taxon's species lifespans" do
      before do
        make_statistics_set
        @taxon.statistics.calculate_lifespan
      end
      it "should calculate statistics" do
        @taxon.statistics.minimum_lifespan.should == 10.0
        @taxon.statistics.maximum_lifespan.should == 40.0
        @taxon.statistics.average_lifespan.should == 25.0
        @taxon.statistics.standard_deviation_lifespan.should be_close(12.910, 0.001)
      end
    end
  end
  
  describe "calculate_birth_weight" do
    context "for a given species' birth weights" do
      before do
        make_statistics_set
        @species1.statistics.calculate_birth_weight
      end
      it "should calculate statistics" do
        @species1.statistics.minimum_birth_weight.should == 10.0
        @species1.statistics.maximum_birth_weight.should == 20.0
        @species1.statistics.average_birth_weight.should == 15.0
        @species1.statistics.standard_deviation_birth_weight.should be_close(7.071, 0.001)
      end
    end
    context "for a given taxon's species birth weights" do
      before do
        make_statistics_set
        @taxon.statistics.calculate_birth_weight
      end
      it "should calculate statistics" do
        @taxon.statistics.minimum_birth_weight.should == 10.0
        @taxon.statistics.maximum_birth_weight.should == 40.0
        @taxon.statistics.average_birth_weight.should == 25.0
        @taxon.statistics.standard_deviation_birth_weight.should be_close(12.910, 0.001)
      end
    end
  end
  
  describe "calculate_adult_weight" do
    context "for a given species' adult weights" do
      before do
        make_statistics_set
        @species1.statistics.calculate_adult_weight
      end
      it "should calculate statistics" do
        @species1.statistics.minimum_adult_weight.should == 10.0
        @species1.statistics.maximum_adult_weight.should == 20.0
        @species1.statistics.average_adult_weight.should == 15.0
        @species1.statistics.standard_deviation_adult_weight.should be_close(7.071, 0.001)
      end
    end
    context "for a given taxon's species adult weights" do
      before do
        make_statistics_set
        @taxon.statistics.calculate_adult_weight
      end
      it "should calculate statistics" do
        @taxon.statistics.minimum_adult_weight.should == 10.0
        @taxon.statistics.maximum_adult_weight.should == 40.0
        @taxon.statistics.average_adult_weight.should == 25.0
        @taxon.statistics.standard_deviation_adult_weight.should be_close(12.910, 0.001)
      end
    end
  end
  
  describe "calculate_litter_size" do
    context "for a given species' litter sizes" do
      before do
        make_statistics_set
        @species1.statistics.calculate_litter_size
      end
      it "should calculate statistics" do
        @species1.statistics.minimum_litter_size.should == 10.0
        @species1.statistics.maximum_litter_size.should == 20.0
        @species1.statistics.average_litter_size.should == 15.0
        @species1.statistics.standard_deviation_litter_size.should be_close(7.071, 0.001)
      end
    end
    context "for a given taxon's species litter sizes" do
      before do
        make_statistics_set
        @taxon.statistics.calculate_litter_size
      end
      it "should calculate statistics" do
        @taxon.statistics.minimum_litter_size.should == 10.0
        @taxon.statistics.maximum_litter_size.should == 40.0
        @taxon.statistics.average_litter_size.should == 25.0
        @taxon.statistics.standard_deviation_litter_size.should be_close(12.910, 0.001)
      end
    end
  end
  
end
