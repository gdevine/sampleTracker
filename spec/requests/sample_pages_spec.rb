require 'spec_helper'

describe "Sample pages:" do

  Sunspot.remove_all!
  Sunspot.commit
  
  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do  
    
    describe "for signed-in users" do
      
      before { sign_in user }
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
          sign_in user
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
    
    let!(:pending_sample) { FactoryGirl.create(:sample, owner: user,
                                                sampled: false) }              
                                                                            
    let!(:sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                         ) }  
                                                         
    let!(:non_subs_sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                         ) }                                                       
                                                         
    let!(:sub_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 4,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true,
                                                        parent: sampled_sample,
                                                        is_primary: false
                                                         ) }  
                                                                  
    let!(:sub_sample2) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 4,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 11, 3),
                                                        sampled: true,
                                                        parent: sampled_sample,
                                                        is_primary: false
                                                         ) }                                                                                                                                                      
    
    describe "for signed-in users" do
      
      before { sign_in user }
      
      describe "on a 'pending' sample" do
        
        before { visit sample_path(pending_sample) }
        
        let!(:page_heading) {"Sample " + pending_sample.id.to_s}
        
        it { should have_selector('h1', :text => page_heading) }
        it { should have_title(full_title('Sample View')) }
        it { should_not have_title('| Home') }  
        it { should have_button('Edit Sample') }
        it { should have_button('Delete Sample') } 
        it { should have_selector('input[value="Add Subsample"][disabled="disabled"]') }  
              
        describe "when clicking the edit button" do
          before { click_button "Edit Sample" }
          let!(:page_heading) {"Edit Sample " + pending_sample.id.to_s}
          
          describe 'should have a page heading for editing the correct sample' do
            it { should have_content(page_heading) }
          end
        end
        
      end
      
      describe "on a 'sampled' sample" do
        
        before { visit sample_path(sampled_sample) }
        
        it { should have_button('Add Subsample') }
        it { should_not have_button('View Parent') } 
        it { should_not have_selector('input[value="Add Subsample"][disabled="disabled"]') }   # Check that it's not disabled
        it { should have_content("Subsamples associated with Sample #{sampled_sample.id.to_s}")}
        
        describe "when clicking the add subsample button" do
          before { click_button "Add Subsample" }
          let!(:page_heading) {"New Sample (subsample of #{sampled_sample.id.to_s})"}
          
          describe 'should have a page heading for adding a new subsample of the current sample' do
            it { should have_content(page_heading) }
          end
        end
        
        describe "should show the samples belonging to this sample set" do
        
          let!(:first_sample_id) { sampled_sample.subsamples.first.id }
          let!(:last_sample_id) { sampled_sample.subsamples.last.id }
          # before { visit sample_set_path(sample_set) }
          it { should have_selector('table tr th', text: 'Sample ID') } 
          it { should have_selector('table tr td', text: first_sample_id) } 
          it { should have_selector('table tr td', text: last_sample_id) } 
        end
        
      end
      
      describe "on a subsample" do
        
        before { visit sample_path(sub_sample) }
        
        it { should have_button('View Parent') } 
        it { should have_content("Sample #{sub_sample.id.to_s} (subsample of #{sampled_sample.id.to_s})")}
        it { should have_selector('input[value="Add Subsample"][disabled="disabled"]') } # Check that the add subsample button is disabled
        it { should have_content("Subsamples associated with Sample #{sub_sample.id}")}
        it { should have_content("Subsamples can not be derived from existing Subsamples")}

        
        describe "when clicking the 'View Parent' button" do
          let!(:page_heading) {"Sample #{sampled_sample.id}"}
          before { click_button "View Parent" }
          
          describe 'should have a page heading for viewing the parent sample of the current sample' do
            it { should have_content(page_heading) }
          end
          
          describe "should have the Add Subsample button activated" do
            it { should have_button('Add Subsample') }
          end
          
        end
        
      end
      
      describe "on a non-subsample containing 'sampled' sample" do
        
        before { visit sample_path(non_subs_sampled_sample) }
        
        it { should have_button('Add Subsample') }
        it { should_not have_selector('input[value="Add Subsample"][disabled="disabled"]') }   # Check that it's not disabled
        it { should have_content("Subsamples associated with Sample #{non_subs_sampled_sample.id}")}
        it { should have_content("This Sample is not currently associated with any Subsamples")}
        
        describe "when clicking the add subsample button" do
          before { click_button "Add Subsample" }
          let!(:page_heading) {"New Sample (subsample of #{non_subs_sampled_sample.id.to_s})"}
          
          describe 'should have a page heading for adding a new subsample of the current sample' do
            it { should have_content(page_heading) }
          end
        end
        
      end
      
      describe "who don't own the current sample" do
        let(:non_owner) { FactoryGirl.create(:user) }
        before do 
          sign_in non_owner
          visit sample_path(pending_sample)
        end 
       
        describe "should not see the edit and delete buttons" do
          it { should_not have_button('Edit Sample') }
          it { should_not have_button('Delete Sample') }
          it { should_not have_button('Add Subsample') }
        end 
      end
    
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit sample_path(pending_sample) }
        it { should have_title('Sign in') }
        it { should_not have_button('Edit Sample') }
        it { should_not have_button('Delete Sample') }
        it { should_not have_button('Add Subsample') }
      end
    end
    
  end
  
  
  describe "sample destruction" do
    let!(:pending_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        sampled: false) }
    
    let!(:sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                        ) }      
                                                             
    let!(:non_subs_sampled_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 3,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true
                                                         ) }                                                                                                                
                                                         
    let!(:sub_sample) { FactoryGirl.create(:sample, owner: user, 
                                                        tree: 4,
                                                        plot: 1,
                                                        ring:2,
                                                        date_sampled: Date.new(2012, 12, 3),
                                                        sampled: true,
                                                        parent: sampled_sample,
                                                        is_primary: false
                                                         ) }  
    
    

    describe "as correct user" do
      before { sign_in user }
      
      describe "of a non-complete sample" do
        before { visit sample_path(pending_sample) }

        it "should delete" do
          expect { click_button "Delete Sample" }.to change(Sample, :count).by(-1)
        end
      end
      
      describe "of a completed non-subsamples sample" do
        before { visit sample_path(non_subs_sampled_sample) }
        it "should delete" do
          expect { click_button "Delete Sample" }.to change(Sample, :count).by(-1)
        end
      end
      
      describe "of a completed sample with subsamples" do
        before { visit sample_path(sampled_sample) }
        it "should not delete" do
          expect { click_button "Delete Sample" }.not_to change(Sample, :count)
        end
        
        describe "should display an error message" do
          before { click_button "Delete Sample" }
          let!(:error_message) {"Unable to delete a Sample with associated Subsamples. Remove any Subsamples first."}
          
          it { should have_content(error_message) }
        end
      end
      
    end
    
  end
  
  
  describe "New page" do
    
    describe "for signed-in users" do
      
      let!(:myfacility) { FactoryGirl.create(:facility, contact: user) } 
      let!(:mystoragelocation) { FactoryGirl.create(:storage_location, custodian: user, code:'blabla') } 
      before { sign_in user }
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
          find('#sample_facility_id').find(:xpath, 'option['+myfacility.id.to_s+']').select_option
          fill_in 'sample_project_id', with: 1
          fill_in 'sample_tree', with: 4
          fill_in 'sample_plot', with: 4
          fill_in 'sample_ring', with: 1
          find('#sample_storage_location_id').find(:xpath, 'option['+mystoragelocation.id.to_s+']').select_option
          fill_in 'sample_date_sampled', with: Date.new(2012, 12, 3)
        end
        
        it "should create a sample" do
          expect { click_button "Submit" }.to change(Sample, :count).by(1)
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
    
    let!(:sample) { FactoryGirl.create(:sample, owner: user) }
    
    describe "for signed-in users" do
    
      before { sign_in user }
      let!(:myfacility) { sample.facility }
      before { visit edit_sample_path(sample) }
      
      it { should have_content('Edit Sample ' + sample.id.to_s) }
      it { should have_title(full_title('Edit Sample')) }
      
      it { should_not have_title('| Home') }
      it { should_not have_selector('#sample_sample_set_id') }
      
      it { should have_content("Mark as 'Complete'?") }
            
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
          find('#sample_facility_id').find(:xpath, 'option['+myfacility.id.to_s+']').select_option
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
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit edit_sample_path(sample) }
        it { should have_title('Sign in') }
      end
    end
  end
  
end
  
