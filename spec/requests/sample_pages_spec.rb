require 'spec_helper'

describe "Sample pages:" do

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
      
      describe "with samples in the system" do
        let!(:facility) { FactoryGirl.create(:facility) }
        before do
          FactoryGirl.create(:sample, owner: user, tree: 45, facility: facility)
          FactoryGirl.create(:sample, owner: user, tree: 46, facility: facility)
          visit samples_path
        end
        
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Facility')
        end
                   
        it "should list each sample" do
          SampleSet.paginate(page: 1).each do |sample|
            expect(page).to have_selector('table tr td', text: sample.facility_id)
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
  

  describe "New page" do
    
    describe "for signed-in users" do
    
      describe "when viewing a primary sample"
    
        let!(:myfacility) { FactoryGirl.create(:facility, contact: user, description: 'a new description') } 
        before { sign_in user }
        before { visit new_sample_path }
        
        it { should have_content('New Sample') }
        it { should have_content('MYFAC_') }
        it { should have_title(full_title('New Sample')) }
        it { should_not have_title('| Home') }
        it { should have_selector('#sample_facility_id') }
        
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
    
         let(:treenum) { 5 }
          before do
            find('#sample_facility_id').find(:xpath, 'option['+myfacility.id.to_s+']').select_option
            fill_in 'sample_project_id', with: 1
            fill_in 'sample_tree', with: treenum
            fill_in 'sample_sampled', with: 'true'
            fill_in 'sample_date_sampled', with: Date.new(2012, 12, 3)
          end
          
          it "should create a sample" do
            expect { click_button "Submit" }.to change(Sample, :count).by(1)
          end
        end
        
      end
      
      describe "when viewing a subsample"
    
        let!(:myfacility) { FactoryGirl.create(:facility, contact: user, description: 'a new description') } 
        before { sign_in user }
        before { visit new_samples_sample_path }
        
        it { should have_content('New Sample') }
        it { should have_content('MYFAC_') }
        it { should have_title(full_title('New Sample')) }
        it { should_not have_title('| Home') }
        it { should have_selector('#sample_facility_id') }
        
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
    
         let(:treenum) { 5 }
          before do
            find('#sample_facility_id').find(:xpath, 'option['+myfacility.id.to_s+']').select_option
            fill_in 'sample_project_id', with: 1
            fill_in 'sample_tree', with: treenum
            fill_in 'sample_sampled', with: 'true'
            fill_in 'sample_date_sampled', with: Date.new(2012, 12, 3)
          end
          
          it "should create a sample" do
            expect { click_button "Submit" }.to change(Sample, :count).by(1)
          end
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
  
  
  describe "Show page" do
    
    let!(:facility) { FactoryGirl.create(:facility, code: 'faccode2') }
    let!(:sample) { FactoryGirl.create(:sample, owner: user, 
                                                facility: facility, 
                                                project_id: 3, 
                                                tree: 4,
                                                date_sampled: Date.new(2012, 12, 3)
                                                ) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit sample_path(sample) }
      
      let!(:page_heading) {"Sample " + sample.id.to_s}
      
      it { should have_selector('h1', :text => page_heading) }
      it { should have_title(full_title('Sample View')) }
      it { should_not have_title('| Home') }  
      it { should have_button('Edit Sample') }
      it { should have_button('Delete Sample') }
      
      describe "when clicking the edit button" do
        before { click_button "Edit Sample" }
        let!(:page_heading) {"Edit Sample " + sample.id.to_s}
        
        describe 'should have a page heading for editing the correct sample' do
          it { should have_content(page_heading) }
        end
      end
      
      describe "when clicking the add subsample button" do
        before { click_button "Add Subsample" }
        let!(:page_heading) {"New Sample (subsample of #{sample.id.to_s})"}
        
        describe 'should have a page heading for adding a new subsample of the current sample' do
          it { should have_content(page_heading) }
        end
      end
      
      describe "who don't own the current sample" do
         let(:non_owner) { FactoryGirl.create(:user) }
         before do 
           sign_in non_owner
           visit sample_path(sample)
         end 
         
         describe "should not see the edit and delete buttons" do
           it { should_not have_button('Edit Sample') }
           it { should_not have_button('Delete Sample') }
         end 

      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit sample_path(sample) }
        it { should have_title('Sign in') }
        it { should_not have_button('Edit Sample') }
        it { should_not have_button('Delete Sample') }
      end
    end
    
  end
  
  
  describe "sample destruction" do
    let!(:sample) { FactoryGirl.create(:sample, owner: user, tree: 60) }

    describe "as correct user" do
      before { sign_in user }
      before { visit sample_path(sample) }

      it "should delete a sample" do
        expect { click_button "Delete Sample" }.to change(Sample, :count).by(-1)
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