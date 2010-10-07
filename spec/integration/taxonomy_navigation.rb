require 'spec_helper'

# make sure we have biological classification before we navigate a heirarchy
make_biological_classification(5)

context "User viewing the taxa in a class" do
  subject { Taxon.find_by_rank(2)}
  let(:user) { User.make }
  
  before(:each) do
    visit "/class/#{subject.name}"
  end
  
  before(:all) do
    stub_karma_server
  end
  
  it "should have a class dropdown with the class taxon selected" do
    find(:css, "select#taxonomic_selector_2").value.should == subject.name
  end
  
  context "when clicking 'all' in the Phylum dropdown" do
    subject { Taxon.find_by_rank(2)}
    
    before(:all) do
      Capybara.current_driver = :selenium
      visit "/class/#{subject.name}"
      select "All", :from => "Phylum"
    end
    
    context "we are sent to the class taxon's kingdom page" do
      it "should have the taxonomy dropdown with all phylums selected" do
        page.should have_xpath("//select[@id='taxonomic_selector_0']", :text => "Animalia")
        page.should have_xpath("//select[@id='taxonomic_selector_1']", :text => "All")
      end
    end
  end
  
  after(:all) do
    Capybara.use_default_driver
  end
end
