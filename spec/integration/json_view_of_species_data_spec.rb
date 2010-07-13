# require 'spec_helper'
# require 'json'
# require 'pp'
# 
# context "User viewing the species detail page with a json format" do
#   
#   let(:taxon) { Taxon.find_by_rank(5) }
#   let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id) }
# 
#   before do
#     # make sure we have biological classification before we create species
#     make_biological_classification(5)
#     taxon
#     species
#     3.times { species.adult_weights.make  }
#     3.times { species.birth_weights.make  }
#     3.times { species.lifespans.make  }
#     3.times { species.litter_sizes.make  }
#     visit data_species_path(:taxon_id => taxon.id, :format => :json)
#   end
#   
#   it "should return JSON" do
#     JSON.parse(page.body)[0].should == JSON.parse(
#       "{
#         \"name\":\"#{species.name}\",
#         \"litter_size\":#{species.litter_size},
#         \"lifespan_in_days\":#{species.lifespan_in_days},
#         \"adult_weight_in_grams\":#{species.adult_weight_in_grams},
#         \"birth_weight_in_grams\":#{species.birth_weight_in_grams}
#       }"
#     )
#   end
#   
# end