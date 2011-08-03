require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Statistics do
  
  before do
    make_statistics_set
  end
  
  context 'on a species' do
    context 'for a default set of annotations' do
      it 'appends the proper units and adds two decimal places' do
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
    context 'when the maximum lifespan is 100 days' do
      before do
        @species1.lifespans.create!(:units => 'Days', :value_in_days => 100)
      end
      describe '#maximum_lifespan' do
        it 'is 3.33 months' do
          @species1.statistics.maximum_lifespan.should == '3.33 months'
        end
      end
    end
    context 'when the maximum lifespan is 9,000 days' do
      before do
        @species1.lifespans.create!(:units => 'Days', :value_in_days => 9_000)
      end
      describe '#maximum_lifespan' do
        it 'is 24.66 years' do
          @species1.statistics.maximum_lifespan.should == '24.66 years'
        end
      end
    end
    context 'when the maximum lifespan is 2,200,000 days' do
      before do
        @species1.lifespans.create!(:units => 'Days', :value_in_days => 2_200_000)
      end
      describe '#maximum_lifespan' do
        it 'is 6,027.40 years' do
          @species1.statistics.maximum_lifespan.should == '6,027.40 years'
        end
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

