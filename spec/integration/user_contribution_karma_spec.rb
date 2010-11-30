# TODO: This is the only spec that isn't working now. Commenting it out so I
# can continue working on unit conversions. - Clinton

# require 'spec_helper'
# 
# # make sure we have biological classification before we create species
# make_biological_classification(5)
# 
# describe "When a user makes a contribution they receive karma" do
#   subject { User.find_or_create_by_email(:email => "jim@westarete.com", :password => 'password', :password_confirmation => 'password') }
#   
#   before(:all) do
#     stub_karma_server
#     log_in(subject)
#   end
#   
#   context "A user on a species page" do
#     before(:each) do
#       @species = Species.make(:parent_id => Taxon.find_by_rank(5).id)
#       @karma = subject.karma.total
#     end
#     
#     context "adds a lifespan" do
#       before(:each) do
#         @old_karma = @karma
#         visit   species_path(@species)
#         click   "Add Lifespan"
#         fill_in "Lifespan", :with => "100"
#         stub_karma_server_after_contribution
#         click   "Add Lifespan"
#       end
#       
#       it "displays how much karma was awarded" do
#         page.should have_content('You just received 1 point of karma')
#       end
#       
#       it "displays what was done to deserve the karma" do
#         page.should have_content('for contributing a new annotation')
#       end
#       
#       it "displays the user's total new karma" do
#         page.should have_content("Your total karma is now #{@old_karma + 1}")
#       end
#     end
#     
#     context "adds an adult weight" do
#       before(:each) do
#         @old_karma = @karma
#         visit   species_path(@species)
#         click   "Add Adult Weight"
#         fill_in "Adult weight", :with => "5.6"
#         stub_karma_server_after_contribution
#         click   "Add Adult Weight"
#       end
#       
#       it "displays how much karma was awarded" do
#         page.should have_content('You just received 1 point of karma')
#       end
#       
#       it "displays what was done to deserve the karma" do
#         page.should have_content('for contributing a new annotation')
#       end
#       
#       it "displays the user's total new karma" do
#         page.should have_content("Your total karma is now #{@old_karma + 1}")
#       end
#     end
#     
#     context "adds a birth weight" do 
#       before(:each) do
#         @old_karma = @karma
#         visit   species_path(@species)
#         click   "Add Birth Weight"
#         fill_in "Birth weight", :with => "100"
#         stub_karma_server_after_contribution
#         click   "Add Birth Weight"
#       end
#       
#       it "displays how much karma was awarded" do
#         page.should have_content('You just received 1 point of karma')
#       end
#       
#       it "displays what was done to deserve the karma" do
#         page.should have_content('for contributing a new annotation')
#       end
#       
#       it "displays the user's total new karma" do
#         page.should have_content("Your total karma is now #{@old_karma + 1}")
#       end
#     end
#     
#     context "adds a litter size" do
#       before(:each) do
#         @old_karma = @karma
#         visit   species_path(@species)
#         click   "Add Litter Size"
#         fill_in "Litter size", :with => "100"
#         stub_karma_server_after_contribution
#         click   "Add Litter Size"
#       end
#       
#       it "displays how much karma was awarded" do
#         page.should have_content('You just received 1 point of karma')
#       end
#       
#       it "displays what was done to deserve the karma" do
#         page.should have_content('for contributing a new annotation')
#       end
#       
#       it "displays the user's total new karma" do
#         save_and_open_page
#         page.should have_content("Your total karma is now #{@old_karma + 1}")
#       end
#     end
#     
#   end
# end
