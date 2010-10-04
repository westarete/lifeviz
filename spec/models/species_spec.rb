require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Species do
   it { should have_many :birth_weights }
  
  fixtures :taxa
  
  let (:species) { Species.make }
  
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
  end
  
  describe "#validate" do
    before do
      @parent = Taxon.find(5)
      @taxon = Species.new(:name => "Genus 2", :rank => 5, :parent_id => @parent.id)
      @taxon.validate
    end
    it "should ensure rank of parent is at the genus level" do
      @taxon.errors[:base].should == "Species needs to belong to a genus"
    end
  end
  
  describe "#lifespan_in_days" do
    subject { species.lifespan_in_days }
    context "when there are a few lifespans" do
      before do
        species.lifespans.build(:value => 20, :units => "Days")
        species.lifespans.build(:value => 40, :units => "Days")
        species.lifespans.build(:value => 1,  :units => "Months")
      end
      it "should average the lifespans in days" do
        subject.should be_close(30.0, 0.01)
      end
    end
    context "when there are no lifespans" do
      it { should be_nil }
    end
  end
  
  describe "#birth_weight_in_grams" do
    subject { species.birth_weight_in_grams }
    context "when there are a few birth weights" do
      before do
        species.birth_weights.build(:value => 500, :units => "Grams")
        species.birth_weights.build(:value => 1000, :units => "Grams")
        species.birth_weights.build(:value => 1.5,  :units => "Kilograms")
      end
      it "should average the birth weights" do
        subject.should be_close(1000.00, 0.01)
      end
    end
    context "when there are no birth weights" do
      it { should be_nil }
    end
  end
  
  describe "#adult_weight_in_grams" do
    subject { species.adult_weight_in_grams }
    context "when there are a few adult weights" do
      before do
        species.adult_weights.build(:value => 500, :units => "Grams")
        species.adult_weights.build(:value => 1000, :units => "Grams")
        species.adult_weights.build(:value => 1.5,  :units => "Kilograms")
      end
      it "should average the adult weights" do
        subject.should be_close(1000.00, 0.01)
      end
    end
    context "when there are no adult weights" do
      it { should be_nil }
    end
  end
  
  describe "#litter_size" do
    subject { species.litter_size }
    context "when there are a few litter sizes" do
      before do
        species.litter_sizes.build(:measure => 1)
        species.litter_sizes.build(:measure => 3)
        species.litter_sizes.build(:measure => 5)
      end
      it "should average the litter sizes" do
        subject.should be_close(3.0, 0.1)
      end
    end
    context "when there are no litter sizes" do
      it { should be_nil }
    end
  end
  
  # describe "#all_data_available?" do
  #   subject { species.all_data_available? }
  #   context "when there's not data available" do
  #     it { should be_false }
  #   end
  #   context "when there is data available" do
  #     before do 
  #       species.litter_sizes.build(:measure => 1)
  #       species.birth_weights.build(:value => 500, :units => "Grams")
  #       species.lifespans.build(:value => 20, :units => "Days")
  #       species.adult_weights.build(:value => 500, :units => "Grams")
  #     end
  #     it { should be_true}
  #   end
  # end
end

# == Schema Information
#
# Table name: taxa
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  parent_id        :integer
#  lft              :integer
#  rgt              :integer
#  rank             :integer
#  lineage_ids      :string(255)
#  avg_adult_weight :float
#  avg_birth_weight :float
#  avg_lifespan     :float
#  avg_litter_size  :float
#

