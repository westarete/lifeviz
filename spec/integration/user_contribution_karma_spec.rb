require 'spec_helper'

# make sure we have biological classification before we create species
make_biological_classification(5)

describe "When a user makes a contribution" do

  subject { User.find_or_create_by_email(:email => "jim@westarete.com", :password => 'password', :password_confirmation => 'password') }
  
  before(:all) do
     Capybara.current_driver = :selenium
     log_in(subject)
  end

  context "on a species page" do
    let(:karma) {subject.karma.total}
    
    before(:all) do
      @old_karma = karma
      visit root_path
      select "Animalia",   :from => "Kingdom"
      select "Aniphylum",  :from => "Phylum"
      select "Classamilia",:from => "Class"
      select "Aniorder",   :from => "Order"
      select "Famimilia",  :from => "Family"
      select "Genimilia",  :from => "Genus"
      click  "Specimilia"
      click  "Add Lifespan"
      fill_in "Lifespan", :with => "100"
      fill_in "Citation", :with => "From the book of GODZILLWA!"
      click   "Add Lifespan"
    end

    it "displays how much karma was awarded" do
      page.should have_content('You just received 1 point of karma')
    end

    it "displays what was done to deserve the karma" do
      page.should have_content('for contributing a new annotation')
    end

    it "displays the user's total new karma" do
      page.should have_content("Your total karma is now #{@old_karma + 1}")
    end

    it "displays the new current level" do 
      # page.should have_content("your level is #{subject.karma_level}")
    end
  end
  
  after(:all) do
    Capybara.use_default_driver
  end

end
