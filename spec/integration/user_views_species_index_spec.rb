require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species index page" do
  
  let(:species)       { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:other_species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  
  before(:all) do
    stub_karma_server
  end
  
  before do
    species
    other_species
    # TODO: Figure out why we don't have enough stats objects at this point.
    Taxon.rebuild_statistics_objects
    visit genus_path(species.parent.name)
  end
  
  it "sees a list of species" do
    page.should have_xpath("//*[@id='taxa']//a[@href='#{species_path(species)}']", :text => species.name)
  end
  
  context "each species" do
    
    it "has a name" do
      Species.all.each do |specie|
        page.should have_xpath("//*[@class='name']", :text => specie.name)
      end
    end
    
  end
end
