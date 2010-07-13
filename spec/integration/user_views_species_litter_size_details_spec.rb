# require 'spec_helper'
# 
# # make sure we have biological classification before we create species
# make_biological_classification(5)
# 
# context "User viewing the species detail page" do
#   
#   let(:species) { Species.make(:parent_id => Taxon.find_by_rank(5).id ) }
#   let(:bad_litter_size)  { LitterSize.make(:species => species, :measure => 1) }
#   let(:user) { User.make }
#   
#   before do
#     stub_karma_server
#     species
#     bad_litter_size
#     3.times { species.litter_sizes.make  }
#     log_in
#     visit species_path(species)
#   end
#   
#   it 'sees the species scientific name as a title' do
#     page.should have_xpath("//h1", :text => species.name)
#   end
#   
#   context "can see the species' litter size list" do
#     it "has a litter size list" do
#       page.should have_xpath("//*[@id='litter_sizes']")
#     end
#     
#     it "has litter sizes" do
#       species.litter_sizes.each do |l|
#         page.should have_xpath("//*[@class='litter_size']", :text => l.measure.to_s)
#       end
#     end
#   end
#   
#   context "when creating a new litter size" do
#     before do
#       click 'Add Litter Size'
#       fill_in 'litter_size_measure', :with => '5'
#       click_button 'Add Litter Size'
#     end
#     
#     it "sees the species scientific name as title" do
#       page.should have_xpath("//h1", :text => species.name)
#     end
#     
#     it 'sees the new litter size' do
#       page.should have_xpath("//*[@class='litter_size']", :text => '5')
#     end
#     
#     it 'sees a success message' do
#       page.should have_xpath("//*[@class='success']", :text => '5', :text => "Litter size created.")
#     end
#   end
#   
#   context "when editing a litter size" do
#     before do
#       click "edit_litter_size_#{bad_litter_size.id}"
#       fill_in 'litter_size_measure', :with => '14'
#       click_button 'Submit Change'
#     end
#     
#     it 'sees the species scientific name as a title' do
#       page.should have_xpath("//h1", :text => species.name)
#     end
#     
#     it 'sees the new litter size' do
#       page.should have_xpath("//*[@class='litter_size']", :text => '14')
#     end
#   
#     it 'sees success message' do
#       page.should have_xpath("//*[@class='success']", :text => 'Litter size updated.')
#     end
#   end
#   
#   context 'when deleting an litter size' do
#     before do
#       click "delete_litter_size_#{bad_litter_size.id}"
#     end
#     
#     it "sees the species' page" do
#       page.should have_xpath("//h1", :text => species.name)
#     end
#     
#     it 'sees success message' do
#       page.should have_xpath("//*[@class='success']", :text => 'Litter size deleted.')
#     end
#     
#     it "doesn't see the bad litter size" do
#       page.should have_no_xpath("//*[@class='litter_sizes']", :text => '0')
#     end
#   end
#   
# end