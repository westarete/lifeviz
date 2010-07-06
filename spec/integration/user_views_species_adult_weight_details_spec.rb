require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species detail page" do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:bad_adult_weight)  { AdultWeight.make(:species => species, :value => 999.9, :units => "Grams") }
  let(:user) { User.make }
  
  before do
    species
    bad_adult_weight
    3.times { species.adult_weights.make  }
    log_in
    visit species_path(species)
  end
  
  it 'sees the species scientific name as a title' do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  context "can see the species' adult weight list" do
    it "has a adult weight list" do
      page.should have_xpath("//*[@id='adult_weights']")
    end
    
    it "has adult_weights" do
      species.adult_weights.each do |aw|
        page.should have_xpath("//*[@class='adult_weight']", :text => "#{aw.value.to_s} #{aw.units.downcase}")
      end
    end
  end
  
  context "when creating creating a new adult weight" do
    before do
      click 'Add Adult Weight'
      fill_in 'adult_weight_value', :with => '5.5'
      click_button 'Add Adult Weight'
    end
    
    it "sees the species scientific name as title" do
      page.should have_xpath("//h1", :text => species.name)
    end
    
    it 'sees the new adult weight' do
      page.should have_xpath("//*[@class='adult_weight']", :text => '5.5')
    end
    
    it 'sees a success message' do
      page.should have_xpath("//*[@class='success']", :text => '5.5', :text => "Adult weight created.")
    end
  end
  
  context "when editing a adult weight" do
    before do
      click "edit_adult_weight_#{bad_adult_weight.id}"
      fill_in 'adult_weight_value', :with => '22.25'
      click_button 'Submit Change'
    end
    
    it 'sees the species scientific name as a title' do
      page.should have_xpath("//h1", :text => species.name)
    end
    
    it 'sees the new adult weight' do
      page.should have_xpath("//*[@class='adult_weight']", :text => '22.25')
    end
  
    it 'sees success message' do
      page.should have_xpath("//*[@class='success']", :text => 'Adult weight updated.')
    end
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
      page.should have_no_xpath("//*[@class='adult_weights']", :text => '999.9')
    end
  end
  
end