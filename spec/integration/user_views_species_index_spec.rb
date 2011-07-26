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
    visit taxon_path("genus", species.parent.name)
  end
  
  it "sees the breadcrumbs" do
    page.should have_xpath("//*[@class='breadcrumbs']//a[@href='#{taxon_path(:rank => species.parent.rank_in_words.downcase, :taxon => species.parent.name)}']", :text => species.parent.name)
  end
  
end
