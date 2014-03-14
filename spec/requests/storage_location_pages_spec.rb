require 'spec_helper'

describe "Storage Location pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do
    
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit storage_locations_path }
      
      it { should have_content('Storage Location List') }
      it { should have_title(full_title('Storage Location List')) }
      it { should_not have_title('| Home') }
      
      describe "with no storage locations in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Storage Locations found')
        end
      end
      
      describe "with storage locations in the system" do
        before do
          FactoryGirl.create(:storage_location, custodian: user, code: 'L9R9', address: 'An address')
          FactoryGirl.create(:storage_location, custodian: user, code: 'L10R3', address: 'Another address')
          visit storage_locations_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'ID')
          expect(page).to have_selector('table tr th', text: 'Code')
        end
                   
        it "should list each storage location" do
          StorageLocation.paginate(page: 1).each do |storage_location|
            expect(page).to have_selector('table tr td', text: storage_location.id)
            expect(page).to have_selector('table tr td', text: storage_location.code)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit storage_locations_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  

  describe "New page" do
    
    describe "for signed-in users" do
    
      before { sign_in user }
      before { visit new_storage_location_path }
      
      it { should have_content('New Storage Location') }
      it { should have_title(full_title('New Storage Location')) }
      it { should_not have_title('| Home') }
      
      describe "with invalid information" do
  
        it "should not create a storage location" do
          expect { click_button "Submit" }.not_to change(StorageLocation, :count)
        end
  
      end
  
      describe "with valid information" do
  
        before do
          fill_in 'storage_location_code', with: 'L90Rbla' 
          fill_in 'storage_location_building', with: 'L9' 
          fill_in 'storage_location_room', with: '7' 
          fill_in 'storage_location_address', with: 'An address' 
          fill_in 'storage_location_description', with: 'A description of this storage location'
        end
        
        it "should create a storage location" do
          expect { click_button "Submit" }.to change(StorageLocation, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Submit" }
          it { should have_content('Storage location created!') }
          it { should have_title(full_title('Storage Location View')) }
        end
        
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit new_storage_location_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "Show page" do
    
    let!(:storage_location) { FactoryGirl.create(:storage_location, custodian: user, code: 'L9R30', 
                                                    description: 'A description of the storage location'
                                                    ) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit storage_location_path(storage_location) }
      
      let!(:page_heading) {"Storage Location " + storage_location.code}
      
      it { should have_selector('h1', :text => page_heading) }
      it { should have_title(full_title('Storage Location View')) }
      it { should_not have_title('| Home') }  
      it { should have_button('Edit Storage Location') }
      it { should have_button('Delete Storage Location') }
      
      describe "when clicking the edit button" do
        before { click_button "Edit Storage Location" }
        let!(:page_heading) {"Edit Storage Location " + storage_location.code}
        
        describe 'should have a page heading for editing the correct storage location' do
          it { should have_content(page_heading) }
        end
      end
      
      describe "who don't govern the current storage location" do
         let(:non_owner) { FactoryGirl.create(:user) }
         before do 
           sign_in non_owner
           visit storage_location_path(storage_location)
         end 
         
         describe "should not see the edit and delete buttons" do
           it { should_not have_button('Edit Storage Location') }
           it { should_not have_button('Delete Storage Location') }
         end 

      end
      
      describe "should show correct sample associations" do
        before do 
          FactoryGirl.create(:sample, owner: user, facility_id: 2, storage_location: storage_location )
          FactoryGirl.create(:sample, owner: user, facility_id: 3, storage_location: storage_location )
          visit storage_location_path(storage_location)
        end
        
        let!(:first_sample_id) { storage_location.samples.first.id }
        let!(:last_sample_id) { storage_location.samples.last.id }
        
        it { should have_content('Samples associated with this storage location') }
        it { should have_selector('table tr th', text: 'Sample ID') } 
        it { should have_selector('table tr td', text: first_sample_id) } 
        it { should have_selector('table tr td', text: last_sample_id) } 
              
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit storage_location_path(storage_location) }
        it { should have_title('Sign in') }
        it { should_not have_button('Edit Storage Location') }
        it { should_not have_button('Delete Storage Location') }
      end
    end
    
  end
  
  
  describe "storage location destruction" do
    let!(:storage_location) { FactoryGirl.create(:storage_location, custodian: user, code: 'L33R10', description: 'A description of the storage location') }

    describe "as correct user" do
      before { sign_in user }
      before { visit storage_location_path(storage_location) }

      it "should delete a storage location" do
        expect { click_button "Delete Storage Location" }.to change(StorageLocation, :count).by(-1)
      end
    end
  end
  
  
  describe "edit page" do
    
    let!(:storage_location) { FactoryGirl.create(:storage_location, custodian: user, code: 'L33R10', description: 'A description of the storage location') }
    
    describe "for signed-in users" do
    
      before { sign_in user }
      before { visit edit_storage_location_path(storage_location) }
      
      it { should have_content('Edit Storage Location ' + storage_location.code) }
      it { should have_title(full_title('Edit Storage Location')) }
      it { should_not have_title('| Home') }
      
      describe "with invalid information" do
        
          before do
            fill_in 'storage_location_code', with: ''
            click_button "Update"
          end
          
          describe "should return an error" do
            it { should have_content('error') }
          end
  
      end
  
      describe "with valid information" do
  
        before do
          fill_in 'storage_location_code'  , with: 'L5R32'
          fill_in 'storage_location_description'   , with: 'A new description'
        end
        
        it "should update, not add a storage location" do
          expect { click_button "Update" }.not_to change(StorageLocation, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Update" }
          it { should have_content('Storage location updated') }
          it { should have_title(full_title('Storage Location View')) }
        end
      
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit edit_storage_location_path(storage_location) }
        it { should have_title('Sign in') }
      end
    end
  end
    
end