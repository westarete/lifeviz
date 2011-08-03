require 'spec_helper'

make_biological_classification(5)

describe 'User interacts with species litter size' do
  
  let(:user)    { User.find_or_create_by_email(:email => "jim@westarete.com", :password => 'password', :password_confirmation => 'password') }  
  
  before(:all)  do
    Capybara.current_driver = :selenium
    stub_karma_server
    log_in(user) 
  end

  after(:all) { Capybara.use_default_driver }

  context 'a logged in user on the species page' do
    
    subject      { Species.make(:parent_id => Taxon.find_by_rank(5).id) }
    before(:all) { visit species_path(subject) }

    context 'creates a litter size' do
      
      before(:all) do
        click 'Add Litter Size'
        fill_in 'Litter Size', :with => '5'
        click 'Add Litter Size'        
      end
      
      it "should see success message" do
        page.should have_content('Litter size created.')
      end
      
      it "should see the litter size" do
        page.should have_xpath("//*[@class='litter_size']", :text => '5')
      end
      
    end
  end
  
end