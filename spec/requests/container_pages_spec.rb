require 'spec_helper'

describe "Container pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do
    
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit containers_path }
      
      it { should have_content('Containers List') }
      it { should have_title(full_title('Containers List')) }
      it { should_not have_title('| Home') }
      
      describe "with no containers in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Containers found')
        end
      end
      
      describe "with containers in the system" do
        before do
          FactoryGirl.create(:container, owner: user)
          FactoryGirl.create(:container, owner: user)
          visit containers_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'ID')
          expect(page).to have_selector('table tr th', text: 'Type')
        end
                   
        it "should list each container" do
          Container.paginate(page: 1).each do |con|
            expect(page).to have_selector('table tr td', text: con.id)
            expect(page).to have_selector('table tr td', text: con.container_type)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit containers_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  

  describe "New page" do
    
    describe "for signed-in users" do
      
      let!(:mystoragelocation) { FactoryGirl.create(:storage_location, custodian: user, code:'blabla') } 
    
      before { sign_in user }
      before { visit new_container_path }
      
      it { should have_content('New Container') }
      it { should have_title(full_title('New Container')) }
      it { should_not have_title('| Home') }
      
      describe "with invalid information" do
  
        it "should not create a container" do
          expect { click_button "Submit" }.not_to change(Container, :count)
        end
  
      end
  
      describe "with valid information" do
  
        before do
          fill_in 'container_container_type', with: 'box' 
          find('#container_storage_location_id').find(:xpath, 'option['+ (mystoragelocation.id + 1).to_s+']').select_option
          fill_in 'container_description', with: 'A description of this container'
        end
        
        it "should create a container" do
          expect { click_button "Submit" }.to change(Container, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Submit" }
          it { should have_content('Container created!') }
          it { should have_title(full_title('Container View')) }
        end
        
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit new_container_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "Show page" do
    
    let!(:container) { FactoryGirl.create(:container, owner: user ) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit container_path(container) }
      
      let!(:page_heading) {"Container " + container.id.to_s}
      
      it { should have_selector('h1', :text => page_heading) }
      it { should have_title(full_title('Container View')) }
      it { should_not have_title('| Home') }  
      it { should have_button('Edit Container') }
      it { should have_button('Delete Container') }
      
      describe "when clicking the edit button" do
        before { click_button "Edit Container" }
        let!(:page_heading) {"Edit Container " + container.id.to_s}
        
        describe 'should have a page heading for editing the correct container' do
          it { should have_content(page_heading) }
        end
      end
      
      describe "who don't own the current container" do
         let(:non_owner) { FactoryGirl.create(:user) }
         before do 
           sign_in non_owner
           visit container_path(container)
         end 
         
         describe "should not see the edit and delete buttons" do
           it { should_not have_button('Edit Container') }
           it { should_not have_button('Delete Container') }
         end 

      end
      
      describe "should show correct sample associations" do
        let!(:first_sample) { FactoryGirl.create(:sample, owner: user, container_id: container.id, storage_location_id:container.storage_location_id ) }
        let!(:second_sample) { FactoryGirl.create(:sample, owner: user, container_id: container.id, storage_location_id:container.storage_location_id ) }
        
        before do 
          visit container_path(container)
        end
        
        it { should have_content('Samples held within this Container') }
        it { should have_selector('table tr th', text: 'Sample ID') } 
        it { should have_selector('table tr td', text: first_sample.id) } 
        it { should have_selector('table tr td', text: second_sample.id) } 
              
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit container_path(container) }
        it { should have_title('Sign in') }
        it { should_not have_button('Edit Container') }
        it { should_not have_button('Delete Container') }
      end
    end
    
  end
  
  
  # describe "storage location destruction" do
    # let!(:storage_location_empty) { FactoryGirl.create(:storage_location, custodian: user) }
    # let!(:storage_location_with_samples) { FactoryGirl.create(:storage_location, custodian: user, 
                                                                                 # code: 'L33R10', 
                                                                                 # description: 'A description of the storage location') }
    # let!(:sample) { FactoryGirl.create(:sample, owner: user, 
                                                # storage_location: storage_location_with_samples,
                                                # sampled: true
                                                # ) }      
#                                                 
    # describe "as correct user" do
      # before { sign_in user }
#       
      # describe "of an empty storage location" do
        # before { visit storage_location_path(storage_location_empty) }
# 
        # it "should delete" do
          # expect { click_button "Delete Location" }.to change(StorageLocation, :count).by(-1)
        # end
      # end
#       
      # describe "of a non-empty storage location" do
        # before { visit storage_location_path(storage_location_with_samples) }
        # it "should not delete" do
          # expect { click_button "Delete Location" }.not_to change(StorageLocation, :count)
        # end
#         
        # describe "should display an error message" do
          # before { click_button "Delete Location" }
          # let!(:error_message) {"Unable to delete a Storage location that contains samples and/or containers. Relocate these first."}
#           
          # it { should have_content(error_message) }
        # end
      # end
#       
    # end
  # end
  
  
  describe "edit page" do
    
    let!(:mystoragelocation) { FactoryGirl.create(:storage_location, custodian: user, code:'blabla') } 
    let!(:mycontainer) { FactoryGirl.create(:container, owner: user, storage_location_id: mystoragelocation.id) } 
    let!(:mysample) { FactoryGirl.create(:sample, owner: user, storage_location: mystoragelocation, container_id: mycontainer.id ) }   
    
    describe "for signed-in users" do
    
      before { sign_in user }
      before { visit edit_container_path(mycontainer) }
      
      it { should have_content('Edit Container ' + mycontainer.id.to_s) }
      it { should have_title(full_title('Edit Container')) }
      it { should_not have_title('| Home') }
      
      describe "with invalid information" do
        
          before do
            find('#container_storage_location_id').find(:xpath, 'option[normalize-space(text())=""]').select_option
            click_button "Update"
          end
          
          describe "should return an error" do
            it { should have_content('error') }
          end
  
      end
  
      describe "with valid information" do
  
        before do
          fill_in 'container_container_type'  , with: 'box'
          fill_in 'container_description'   , with: 'A new description'
          find('#container_storage_location_id').find(:xpath, 'option['+ (mystoragelocation.id + 1).to_s+']').select_option
        end
        
        it "should update, not add a storage location" do
          expect { click_button "Update" }.not_to change(Container, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Update" }
          it { should have_content('Container updated') }
          it { should have_title(full_title('Container View')) }
        end
      
      end
      
      describe "with differing storage location for container and its contained samples" do
        let!(:newstoragelocation) { FactoryGirl.create(:storage_location, custodian: user, code:'newsl') }
        
     
        describe "should return to view page with containing sample location updated" do
          before do 
            fill_in 'container_container_type'  , with: 'box'
            fill_in 'container_description'   , with: 'A new description'
            find('#container_storage_location_id').find(:xpath, 'option['+ (newstoragelocation.id).to_s+']').select_option     
            click_button "Update"
          end
          
          it { should have_content('Container updated') }
          it { should have_title(full_title('Container View')) }
          
          it { should have_selector('table tr th', text: 'Storage Location') } 
          it { should have_selector('table tr td', text: mycontainer.storage_location.code) } 
        end
      
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit edit_container_path(mycontainer) }
        it { should have_title('Sign in') }
      end
    end
  end
    
end