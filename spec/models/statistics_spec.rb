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
  
end
