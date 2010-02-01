require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lifespan do
  fixtures :taxa
  
  before(:all) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
    Taxon.rebuild_lineages!
  end
  
  before(:each) do
    @species = Species.find(8)
    @lifespan = @species.lifespans.new
  end
  
  describe "#value" do
    
    describe "when units is Years" do
      before(:each) do
        @lifespan.value_in_days = 365
        @lifespan.units = "Years"
      end
      it "should return the value in Years" do
        @lifespan.value.should == 1
      end
    end
    
    describe "when units is Months" do
      before(:each) do
        @lifespan.value_in_days = 360
        @lifespan.units = "Months"
      end
      it "should return the value in Months" do
        @lifespan.value.should == 12
      end
    end
    
    describe "when units is Days" do
      before(:each) do
        @lifespan.value_in_days = 366
        @lifespan.units = "Days"
      end
      it "should return the value in Days" do
        @lifespan.value.should == 366
      end
    end
    
  end
  
  describe "#value=" do
    describe "when units is not set" do
      before(:each) do
        @lifespan.units = nil
        @lifespan.value = 360
      end
      it "should return itself" do
        @lifespan.value.should == 360
      end
      it "should not set value_in_days" do
        @lifespan.value_in_days.should be_nil
      end
    end
    describe "when units is set" do
      before(:each) do
        @lifespan.value = 360
      end
      it "should return itself" do
        @lifespan.value.should == 360
      end
      describe "to Days" do
        before(:each) do
          @lifespan.units = "Days"
        end
        it "should set value_in_days" do
          @lifespan.value.should == 360
        end
      end
      describe "to Months" do
        before(:each) do
          @lifespan.units = "Months"
        end
        it "should set value correctly" do
          @lifespan.value.should == 360
        end
      end
    end
  end
  
  describe "#in_units" do
    before(:each) do
      @lifespan.value_in_days = 360
    end
    describe "with Days" do
      it "should return the value in days" do
        @lifespan.in_units("Days").should == 360
      end
    end
    describe "with Months" do
      it "should return the value in months" do
        @lifespan.in_units("Months").should == 12
      end
    end
    describe "with Years" do
      before(:each) do
        @lifespan.value_in_days = 730
      end
      it "should return the value in years" do
        @lifespan.in_units("Years").should == 2
      end
    end
  end
  
  describe "#to_s" do      
    before(:each) do
      @lifespan.value_in_days = 60
    end
    describe "when units is not set" do
      before(:each) do
        @lifespan.units = nil
      end
      it "should return an empty string" do
        @lifespan.to_s.should == ""
      end
    end
    describe "when units is set" do
      before(:each) do
        @lifespan.units = "Months"
      end
      it "should return '2 months'" do
        @lifespan.to_s.should == "2 months"
      end
    end
    
  end
  
end

# == Schema Information
#
# Table name: lifespans
#
#  id            :integer         not null, primary key
#  species_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  value_in_days :decimal(, )
#  units         :string(255)
#

