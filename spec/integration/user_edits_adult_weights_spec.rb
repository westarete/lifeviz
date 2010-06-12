require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User edits an adult weight for a species" do
  
  let(:species)           { Species.make(:parent_id => Taxon.find_by_rank(5).id )   }
  let(:bad_adult_weight)  { AdultWeight.make(:species => species, :measure => 55.5) }
  
  before do
    species
    2.times { species.adult_weights.make }
    bad_adult_weight
    visit species_path(species)
    click "edit_adult_weight_#{bad_adult_weight.id}"
  end
  
  it 'sees the species scientific name as a title' do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  it 'sees the edit species adult weight page' do
    page.should have_xpath("//h2", :text => 'Editing Adult Weight')
  end
  
  it 'has a place to enter adult weight with bad value' do
    page.should have_xpath("//input[@id='adult_weight_measure']"), :text => '55.5'
  end
  
  context 'when editing an adult weight' do
    
    before do
      fill_in 'adult_weight_measure', :with => '99.99'
      click_button 'Submit Change'
    end
    
    it 'sees the species scientific name as a title' do
      page.should have_xpath("//h1", :text => species.name)
    end
      
    it 'sees the new adult weight' do
      page.should have_xpath("//*[@class='adult_weight']", :text => '99.99')
    end
    
    it 'sees success message' do
      page.should have_xpath("//*[@class='success']", :text => 'Adult weight updated.')
    end
    
  end
    
end