require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species detail page" do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  
  before do
    species
    3.times { species.birth_weights.make  }
    visit species_path(species)
  end
  
  it 'sees the species scientific name as a title' do
    save_and_open_page
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
      save_and_open_page
      page.should have_xpath("//*[@class='birth_weight']", :text => '5.5')
    end
    
    it 'sees a success message' do
      page.should have_xpath("//*[@class='success']", :text => '5.5', :text => "Birth weight created.")
    end
  end
  
end