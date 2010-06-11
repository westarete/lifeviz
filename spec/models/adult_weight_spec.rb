require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# make sure we have biological classification before we create species
make_biological_classification(5)

describe AdultWeight do
  
  let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
  let(:weight)  { AdultWeight.make( :species_id => species ) }
  
  before do
    species
    weight
  end

  it { should belong_to(:species)             }
  it { should validate_presence_of(:measure)  }
  
end