require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User creates an adult weight for a species" do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  
  before do
    species
    2.times { species.adult_weights.make }
    visit species_path(species)
    click 'Add an Adult Weight'
  end
  
  it 'sees the species scientific name as a title' do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  it 'sees the new species adult weight page' do
    page.should have_xpath("//h2", :text => 'Adding Adult Weight')
  end
  
  it 'has a place to enter adult weight' do
    page.should have_xpath("//input[@id='adult_weight_measure']")
  end
  
  context 'when creating a new adult weight' do
    
    before do
      fill_in 'adult_weight_measure', :with => '99.99'
      click_button 'Add Adult Weight'
    end
    
    it 'sees the species scientific name as a title' do
      page.should have_xpath("//h1", :text => species.name)
    end
      
    it 'sees the new adult weight' do
      page.should have_xpath("//*[@class='adult_weight']", :text => '99.99')
    end
    
  end
    
end