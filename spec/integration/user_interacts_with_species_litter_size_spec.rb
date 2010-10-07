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
        fill_in 'Litter size', :with => '5'
        click 'Add Litter Size'        
      end
      
      it "should see success message" do
        page.should have_content('Litter size created.')
      end
      
      it "should see the litter size" do
        page.should have_xpath("//*[@class='litter_size']", :text => '5')
      end
      
      context 'edits the litter size' do
        
        let(:litter_size) { subject.litter_sizes.first }
        
        before(:all) do          
          # find by the id of the button because we have no link text
          click "edit_litter_size_#{litter_size.id}"
          fill_in 'Litter size', :with => '6'
          click 'Submit Change'
        end
        
        it 'should see success message' do
          page.should have_content('Litter size updated.')
        end
        
        it "should see the updated litter size" do
          page.should have_xpath("//*[@class='litter_size']", :text => '6')
        end    
        
        context 'deletes the litter size' do
          
          before(:all) do
            click "delete_litter_size_#{litter_size.id}"
          end
          
          it 'should see success message' do
            page.should have_content('Litter size deleted.')
          end
          
          it "shouldn't see the litter size" do
            page.should_not have_content('6')
          end
          
        end
      end
    end
  end
  
end