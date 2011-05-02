require 'spec_helper'

make_biological_classification(5)

describe 'User interacts with species adult weight' do
  
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

    context 'creates an adult weight' do
      
      before(:all) do
        click 'Add Adult Weight'
        fill_in 'Adult weight', :with => '5.5'
        click 'Add Adult Weight'        
      end
      
      it "should see success message" do
        page.should have_content('Adult weight created.')
      end
      
      it "should see the adult weight" do
        page.should have_xpath("//*[@class='adult_weight']", :text => '5.5')
      end
        
      # context 'deletes the adult weight' do
      #   
      #   let(:weight) { subject.adult_weights.first } 
      #     
      #   before(:all) do
      #     click "delete_adult_weight_#{weight.id}"
      #   end
      #   
      #   it 'should see success message' do
      #     page.should have_content('Adult weight deleted.')
      #   end
      #   
      #   it "shouldn't see the weight" do
      #     page.should_not have_content('6.7')
      #   end
      # end
    end
  end
  
end