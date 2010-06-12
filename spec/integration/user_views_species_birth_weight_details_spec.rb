require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species detail page" do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:bad_birth_weight)  { BirthWeight.make(:species => species, :value => 999.9, :units => "Grams") }
  
  before do
    species
    bad_birth_weight
    3.times { species.birth_weights.make  }
    visit species_path(species)
  end
  
  it 'sees the species scientific name as a title' do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  context "can see the species' birth weight list" do
    it "has a birth weight list" do
      page.should have_xpath("//*[@id='birth_weights']")
    end
    
    it "has birth_weights" do
      species.birth_weights.each do |bw|
        page.should have_xpath("//*[@class='birth_weight']", :text => "#{bw.value} #{bw.units.downcase}")
      end
    end
  end
  
  context "when creating creating a new birth weight" do
    before do
      click 'Add Birth Weight'
      fill_in 'birth_weight_value', :with => '5.5'
      click_button 'Add Birth Weight'
    end
    
    it "sees the species scientific name as title" do
      page.should have_xpath("//h1", :text => species.name)
    end
    
    it 'sees the new birth weight' do
      page.should have_xpath("//*[@class='birth_weight']", :text => '5.5')
    end
    
    it 'sees a success message' do
      page.should have_xpath("//*[@class='success']", :text => '5.5', :text => "Birth weight created.")
    end
  end
  
  context "when editing a birth weight" do
    before do
      click "edit_birth_weight_#{bad_birth_weight.id}"
      fill_in 'birth_weight_value', :with => '22.25'
      click_button 'Submit Change'
    end
    
    it 'sees the species scientific name as a title' do
      page.should have_xpath("//h1", :text => species.name)
    end
    
    it 'sees the new birth weight' do
      page.should have_xpath("//*[@class='birth_weight']", :text => '22.25')
    end
  
    it 'sees success message' do
      page.should have_xpath("//*[@class='success']", :text => 'Birth weight updated.')
    end
  end
  
end