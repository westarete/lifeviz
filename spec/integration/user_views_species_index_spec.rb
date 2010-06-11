require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species index page" do
  
  let(:species)       { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:other_species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:adult_weight)  { AdultWeight.make(:species_id => species.id, :measure => 5)}
  
  before do
    species
    adult_weight      
    other_species
    visit species_index_path
  end
  
  it "sees a list of species" do
    page.should have_xpath("//*[@id='species']//a[@href='#{species_path(species)}']", :text => species.name)
  end
  
  context "each species" do
    
    it "has a name" do
      Species.all.each do |o|
        page.should have_xpath("//*[@class='name']", :text => species.name)
      end
    end
    
    it "has an adult weight list" do
      Species.all.each do |o|
        page.should have_xpath("//*[@class='adult_weights']")
      end
    end
    
    it "has an adult weights" do
      save_and_open_page
      Species.all.each do |o|
        o.adult_weights.each do |aw|
          page.should have_xpath("//*[@class='adult_weight']", :text => aw.measure.to_s)
        end
      end
    end
    
  end
end