require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "Sample pages:" do

  Sunspot.remove_all!
  Sunspot.commit
  
  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do  
    
    describe "for signed-in users" do
      
      before { login_as user }
      before { visit samples_path }
      
      it { should have_content('Sample List') }
      it { should have_title(full_title('Sample List')) }
      it { should_not have_title('| Home') }
      
      describe "with no samples in the system" do
        it "should have an information message" do
          expect(page).to have_content('No Samples found')
        end
      end
      
      describe "with samples in the system", :search => true do  
        before do
          login_as user
          FactoryGirl.create(:sample, owner: user)
          FactoryGirl.create(:sample, owner: user)
          Sunspot.commit
          visit samples_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Facility')
        end
                   
        it "should list each sample" do
          Sample.paginate(page: 1).each do |s|
            expect(page).to have_selector('table tr td', text: s.facility_id)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit samples_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "Show page" do
    
    let(:facility)                 { FactoryGirl.create(:facility) }
    let!(:pending_sample)          { FactoryGirl.create(:sample, owner: user, sampled: false) }              
    let!(:sampled_sample)          { FactoryGirl.create(:sample, owner: user, facility_id: facility.id, sampled: true) }  
    let!(:non_subs_sampled_sample) { FactoryGirl.create(:sample, owner: user, sampled: true) }                                                  
    let!(:sub_sample)              { FactoryGirl.create(:sample, owner: user, facility_id: facility.id, sampled: true, parent: sampled_sample, is_primary: false ) }  
    let!(:sub_sample2)             { FactoryGirl.create(:sample, owner: user, facility_id: facility.id, sampled: true, parent: sampled_sample, is_primary: false ) }                                                                                                                                                      
    
    describe "for signed-in users" do
      
      before { login_as user }  
      
      describe "on a 'pending' sample" do
        
        before { visit sample_path(pending_sample) }
        
        let!(:page_heading) {"Sample " + pending_sample.id.to_s}
        
        it { should have_selector('h2', :text => page_heading) }
        it { should have_title(full_title('Sample View')) }
        it { should_not have_title('| Home') }  
        
        it { should have_link('Options') }
        it { should have_link('Edit Sample') }
        it { should have_link('Delete Sample') } 
        it { should have_link('Print QR Code') } 
        it { should_not have_link("Add Subsample") }  
              
        describe "when clicking the edit link" do
          before { click_link "Edit Sample" }
          let!(:page_heading) {"Edit Sample " + pending_sample.id.to_s}
          
          describe 'should have a page heading for editing the correct sample' do
            it { should have_content(page_heading) }
          end
        end
        
      end
      
      describe "on a 'sampled' sample" do
        
        before { visit sample_path(sampled_sample) }
        
        it { should have_link('Add Subsample') }
        it { should_not have_button('View Parent') } 
        it { should_not have_selector('input[value="Add Subsample"][disabled="disabled"]') }   # Check that it's not disabled
        it { should have_content("Subsamples associated with Sample #{sampled_sample.id.to_s}")}
        
        describe "when clicking the add subsample link" do
          before { click_link "Add Subsample" }
          let!(:page_heading) {"New Sample (subsample of #{sampled_sample.id.to_s})"}
          
          describe 'should have a page heading for adding a new subsample of the current sample' do
            it { should have_content(page_heading) }
          end
        end
        
        describe "should show the samples belonging to this sample set" do
        
          let!(:first_sample_id) { sampled_sample.subsamples.first.id }
          let!(:last_sample_id) { sampled_sample.subsamples.last.id }
          it { should have_selector('table tr th', text: 'Sample ID') } 
          it { should have_selector('table tr td', text: first_sample_id) } 
          it { should have_selector('table tr td', text: last_sample_id) } 
        end
        
      end
      
      describe "on a subsample" do
        
        before { visit sample_path(sub_sample) }
        
        it { should have_link('View Parent') } 
        it { should have_content("Sample #{sub_sample.id.to_s} (subsample of #{sampled_sample.id.to_s})")}
        it { should_not have_link("Add Subsample") } 
        it { should have_content("Subsamples associated with Sample #{sub_sample.id}")}
        it { should have_content("Subsamples can not be derived from existing Subsamples")}

        
        describe "when clicking the 'View Parent' button" do
          let!(:page_heading) {"Sample #{sampled_sample.id}"}
          before { click_link "View Parent" }
          
          describe 'should have a page heading for viewing the parent sample of the current sample' do
            it { should have_content(page_heading) }
          end
          
          describe "should have the Add Subsample button activated" do
            it { should have_link('Add Subsample') }
          end
          
        end
        
      end
      
      describe "on a non-subsample containing 'sampled' sample" do
        
        before { visit sample_path(non_subs_sampled_sample) }
        
        it { should have_link('Add Subsample') }
        it { should_not have_selector('input[value="Add Subsample"][disabled="disabled"]') }   # Check that it's not disabled
        it { should have_content("Subsamples associated with Sample #{non_subs_sampled_sample.id}")}
        it { should have_content("This Sample is not currently associated with any Subsamples")}
        
        describe "when clicking the add subsample button" do
          before { click_link "Add Subsample" }
          let!(:page_heading) {"New Sample (subsample of #{non_subs_sampled_sample.id.to_s})"}
          
          describe 'should have a page heading for adding a new subsample of the current sample' do
            it { should have_content(page_heading) }
          end
        end
        
      end
      
      describe "who don't own the current sample" do
        let(:non_owner) { FactoryGirl.create(:user) }
        before do 
          login_as non_owner
          visit sample_path(pending_sample)
        end 
       
        describe "should not see the edit and delete buttons" do
          it { should_not have_link('Edit Sample') }
          it { should_not have_link('Delete Sample') }
          it { should_not have_link('Add Subsample') }
        end 
      end
    
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit sample_path(pending_sample) }
        it { should have_title('Sign in') }
        it { should_not have_link('Edit Sample') }
        it { should_not have_link('Delete Sample') }
        it { should_not have_link('Add Subsample') }
      end
    end
    
  end
  
  
  describe "sample destruction" do
    let!(:facility) { FactoryGirl.create(:facility) }
    
    let!(:pending_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        sampled: false) }
    
    let!(:sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        facility_id: facility.id,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                        ) }    
                                                         
    let!(:noncomplete_sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        facility_id: facility.id,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: false
                                                        ) }                                                      
                                                             
    let!(:non_subs_sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                         ) }                                                                                                                
                                                         
    let!(:sub_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        facility_id: facility.id,
                                                        tree: 4,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true,
                                                        parent: sampled_sample,
                                                        is_primary: false
                                                         ) }  
                                                         
     let!(:sub_sample2) { FactoryGirl.create(:sample, owner: user, 
                                                        facility_id: facility.id,
                                                        tree: 4,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true,
                                                        parent: noncomplete_sampled_sample,
                                                        is_primary: false
                                                         ) }                                                       
    
    let!(:sample_set) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
    

    describe "as correct user" do
      before { login_as user }
      
      describe "of a non-complete sample" do
        before { visit sample_path(pending_sample) }

        it "should delete" do
          expect { click_link "Delete Sample" }.to change(Sample, :count).by(-1)
        end
      end
      
      describe "of a completed non-subsamples sample" do
        before { visit sample_path(non_subs_sampled_sample) }
        it "should not delete" do
          expect { click_link "Delete Sample" }.not_to change(Sample, :count)
        end
        
        describe "should display an error message" do
          before { click_link "Delete Sample" }
          let!(:error_message) {"Unable to delete a Sample marked as 'completed'. Mark as 'not complete' before attempting to delete"}
          
          it { should have_content(error_message) }
        end
      end
      
      describe "of a completed sample with subsamples" do
        before { visit sample_path(sampled_sample) }
        it "should not delete" do
          expect { click_link "Delete Sample" }.not_to change(Sample, :count)
        end
        
        describe "should display an error message" do
          before { click_link "Delete Sample" }
          let!(:error_message) {"Unable to delete a Sample marked as 'completed'. Mark as 'not complete' before attempting to delete"}
          
          it { should have_content(error_message) }
        end
      end
      
      describe "of a non-completed sample with subsamples" do
        before { visit sample_path(noncomplete_sampled_sample) }
        it "should not delete" do
          expect { click_link "Delete Sample" }.not_to change(Sample, :count)
        end
        
        describe "should display an error message" do
          before { click_link "Delete Sample" }
          let!(:error_message) {"Unable to delete a Sample with associated Subsamples. Remove any Subsamples first."}
          
          it { should have_content(error_message) }
        end
      end
      
      describe "of a sample set sample" do
        let(:num_samples_old) { sample_set.num_samples }
        before do 
          visit sample_path(sample_set.samples.first)
        end 
        it "should delete" do
          expect { click_link "Delete Sample" }.to change(Sample, :count).by(-1)
        end
        it "should subtract 1 from the total samples within a sample set" do
          click_link "Delete Sample"
          num_samples_old.should == sample_set.reload.num_samples+1
        end
      end
      
    end
    
  end
  
  
  describe "New page" do
    
    describe "for signed-in users" do
      
      let!(:myfacility) { FactoryGirl.create(:facility, contact: user) } 
      let!(:mystoragelocation) { FactoryGirl.create(:storage_location, custodian: user, code:'blabla') } 
      before { login_as user }
      before { visit new_sample_path }            
      
      it { should have_content('New Sample') }
      it { should have_content('MYFAC_') }
      it { should have_title(full_title('New Sample')) }
      it { should_not have_title('| Home') }
      it { should have_selector('#sample_facility_id') }
      it { should_not have_selector('#sample_sample_set_id') }
      
      it { should_not have_content("Mark as 'Complete'?") }
            
      describe "with invalid information" do
        
        it "should not create a sample" do
          expect { click_button "Submit" }.not_to change(Sample, :count)
        end
                
        before do
          click_button "Submit"
        end
        describe "should return an error" do
          it { should have_content('error') }
        end
        
      end
  
      describe "with valid information" do
        
        before do
          find('#sample_facility_id').find(:xpath, 'option['+(myfacility.id + 1).to_s+']').select_option
          fill_in 'sample_project_id', with: 1
          fill_in 'sample_tree', with: 4
          fill_in 'sample_plot', with: 4
          fill_in 'sample_ring', with: 1
          find('#sample_storage_location_id').find(:xpath, 'option['+(mystoragelocation.id + 1).to_s+']').select_option
          fill_in 'sample_date_sampled', with: Date.new(2012, 12, 3)
        end
        
        describe "should return to view page" do
          before { click_button "Submit" }
          it { should have_content('Sample created!') }
        end
        
        it "should create a sample" do
          expect { click_button "Submit" }.to change(Sample, :count).by(1)
        end
        
      end  
      
      describe "for a subsample" do
        let!(:sample) { FactoryGirl.create(:sample, owner: user, facility_id: myfacility.id) }
        
        before { login_as user }
        before { visit sample_path(sample) }
        
        before { click_link "Add Subsample" }
          
        describe 'should have edit option for project but not facility' do
          it { should have_selector('input[id="sample_facility_id"][type="hidden"]') }
          it { should have_selector('input[id="sample_project_id"]') }
          it { should_not have_selector('input[id="sample_project_id"][type="hidden"]') }
        end
        
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit new_sample_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "edit page" do
    let!(:facility) { FactoryGirl.create(:facility) }
    let!(:sample) { FactoryGirl.create(:sample, owner: user, facility_id: facility.id) }
    let!(:nonsubs_sample) { FactoryGirl.create(:sample, owner: user, facility_id: facility.id) }
    let!(:subsample) { FactoryGirl.create(:sample, owner: user, facility_id: facility.id, is_primary: false, parent_id: sample.id) }
    let!(:myfacility) { sample.facility }
    
    describe "for signed-in users on a primary sample" do
    
      before { login_as user }
      before { visit edit_sample_path(sample) }
      
      it { should have_content('Edit Sample ' + sample.id.to_s) }
      it { should have_title(full_title('Edit Sample')) }
      
      it { should_not have_title('| Home') }
      it { should_not have_selector('#sample_sample_set_id') }
      
      it { should have_content("Mark as 'Complete'?") }
      
      describe "that has subsamples" do
        it { should have_content("Note - Editing a Parent Sample will automatically update all associated subsample details") }
      end
       
      describe "with invalid information" do
        
          before do
            fill_in 'sample_project_id', with: ''
            click_button "Update"
          end
          
          describe "should return an error" do
            it { should have_content('error') }
          end
  
      end
  
      describe "with valid information" do
  
        before do
          find('#sample_facility_id').find(:xpath, 'option['+(myfacility.id+1).to_s+']').select_option
          fill_in 'sample_project_id'   , with: 4
          fill_in 'sample_date_sampled', with: Date.new(2012, 12, 6)
        end
        
        it "should update, not add a sample" do
          expect { click_button "Update" }.not_to change(Sample, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Update" }
          it { should have_content('Sample updated') }
        end
      
      end
      
      describe "with changing the location when it is part of a container" do
        
        let!(:mystoragelocation) { FactoryGirl.create(:storage_location, custodian: user) } 
        let!(:mycontainer) { FactoryGirl.create(:container, owner: user, storage_location_id: mystoragelocation.id ) }
        let!(:container_sample) { FactoryGirl.create(:sample, owner: user, container_id: mycontainer.id, storage_location_id:mycontainer.storage_location.id, is_primary: true ) }
        let!(:newstoragelocation) { FactoryGirl.create(:storage_location, custodian: user) } 
  
        before do
          visit edit_sample_path(container_sample)
          find('#sample_storage_location_id').find(:xpath, 'option['+(newstoragelocation.id+1).to_s+']').select_option
        end
        
        it "should not change the sample count" do
          expect { click_button "Update" }.not_to change(Sample, :count).by(1)
        end
        
        describe "should return an error" do
          let!(:error_message) {"Unable to change the location of a Sample that is housed in a container. Either remove the sample from the container or edit the location of the container directly"}
          before { click_button "Update" }
          
          it { should have_title(full_title('Edit Sample')) }
          it { should have_content(error_message) }
        end
      
      end
      
    end
    
    describe "for signed-in users on a primary sample that does not have subsamples" do
      before { login_as user }
      before { visit edit_sample_path(nonsubs_sample) }
      it { should_not have_content("Note - Editing a Parent Sample will automatically update all associated subsample details") }
    end
    
    describe "for signed-in users on a subsample" do
      before { login_as user }
      before { visit edit_sample_path(subsample) }
      
      it { should have_content('Edit Sample ' + subsample.id.to_s + ' (subsample of '+subsample.parent_id.to_s+')' )}
      it { should have_content('Adopted details from parent sample')}
      it { should have_selector('input[id="sample_facility_id"][type="hidden"]') }
      it { should have_selector('input[id="sample_project_id"]') }
      it { should_not have_selector('input[id="sample_project_id"][type="hidden"]') }
      
      describe "with invalid information" do
        before do
          find('#sample_storage_location_id').find(:xpath, 'option[normalize-space(text())=""]').select_option
          click_button "Update"
        end
        
        describe "should return an error" do
          it { should have_content('error') }
        end
        
        describe "should be returned to edit subsample page" do
          it { should have_content('Adopted details from parent sample') }
        end
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit edit_sample_path(sample) }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
end
  
