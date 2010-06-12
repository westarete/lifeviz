require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

context "User viewing the species detail page" do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  
  before do
    species
    3.times { species.litter_sizes.make  }
    visit species_path(species)
  end
  
  it 'sees the species scientific name as a title' do
    page.should have_xpath("//h1", :text => species.name)
  end
  
  context "can see the species' litter size list" do
   
    it "has a litter size list" do
      save_and_open_page
      page.should have_xpath("//*[@id='litter_sizes']")
    end
    
    it "has litter sizes" do
      species.litter_sizes.each do |l|
        page.should have_xpath("//*[@class='litter_size']", :text => l.measure.to_s)
      end
    end
    
  end
  
end