require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User deletes an adult weight for a species" do
  
  let(:species)           { Species.make(:parent_id => Taxon.find_by_rank(5).id )   }
  let(:bad_adult_weight)  { AdultWeight.make(:species => species, :measure => 55.5) }
  
  before do
    species
    2.times { species.adult_weights.make }
    bad_adult_weight
    visit species_path(species)
  end
  
  it "sees the species' page" do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  context 'when deleting an adult weight' do
    
    before do
      # NOTE: link_to 'delete', :method => delete is no good... use button_to instead -jm
      click "delete_adult_weight_#{bad_adult_weight.id}"
    end
    
    it "sees the species' page" do
      page.should have_xpath("//h1", :text => species.name)
    end
    
    it 'sees success message' do
      page.should have_xpath("//*[@class='success']", :text => 'Adult weight deleted.')
    end
    
    it "doesn't see the bad adult weight" do
      page.should_not have_xpath("//*[@class='adult_weight']", :text => '55.5')
    end
    
  end
end