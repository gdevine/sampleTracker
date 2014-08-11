require 'spec_helper'

describe "Facility pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do
    
    describe "for signed-in users" do
      
      before do 
        sign_in(user)
        visit facilities_path
      end
      
      it { should have_content('Facilities') }
      it { should have_title(full_title('Facility List')) }
      it { should_not have_title('| Home') }
      
      describe "with no facilities in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Facilities found')
        end
      end
      
      describe "with facilities in the system" do
        before do
          FactoryGirl.create(:facility, contact: user, code: 'FACE')
          FactoryGirl.create(:facility, contact: user, code: 'ROS')
          visit facilities_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Facility ID')
          expect(page).to have_selector('table tr th', text: 'Facility Code')
        end
                   
        it "should list each facility" do
          Facility.paginate(page: 1).each do |facility|
            expect(page).to have_selector('table tr td', text: facility.id)
            expect(page).to have_selector('table tr td', text: facility.code)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit facilities_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  

  # describe "New page" do
#     
    # describe "for signed-in users" do
#     
      # before { login_as user }
      # before { visit new_facility_path }
#       
      # it { should have_content('New Facility') }
      # it { should have_title(full_title('New Facility')) }
      # it { should_not have_title('| Home') }
#       
      # describe "with invalid information" do
#   
        # it "should not create a facility" do
          # expect { click_button "Submit" }.not_to change(Facility, :count)
        # end
#   
      # end
#   
      # describe "with valid information" do
#   
        # before do
          # fill_in 'facility_code', with: 'FACE' 
          # fill_in 'facility_description', with: 'A description of the facility'
        # end
#         
        # it "should create a facility" do
          # expect { click_button "Submit" }.to change(Facility, :count).by(1)
        # end
#         
        # describe "should return to view page" do
          # before { click_button "Submit" }
          # it { should have_content('Facility created!') }
          # it { should have_title(full_title('Facility View')) }
        # end
#         
      # end
#       
    # end
#     
    # describe "for non signed-in users" do
      # describe "should be redirected back to signin" do
        # before { visit new_facility_path }
        # it { should have_title('Sign in') }
      # end
    # end
#     
  # end
  
  
  describe "Show page" do
    
    let!(:facility) { FactoryGirl.create(:facility, contact: user, 
                                                    code: 'FACE', 
                                                    description: 'A description of the facility'
                                                    ) }
        
    describe "for signed-in users" do
      
      before { sign_in(user) }
      before { visit facility_path(facility) }
      
      let!(:page_heading) {"Facility " + facility.code}
      
      it { should have_selector('h2', :text => page_heading) }
      it { should have_title(full_title('Facility View')) }
      it { should_not have_title('| Home') }  
      # it { should have_link('Edit Facility') }
      # it { should have_link('Delete Facility') }
      
      # describe "when clicking the edit button" do
        # before { click_link "Edit Facility" }
        # let!(:page_heading) {"Edit Facility " + facility.code}
#         
        # describe 'should have a page heading for editing the correct facility' do
          # it { should have_content(page_heading) }
        # end
      # end
      
      # describe "who don't own the current facility" do
         # let(:non_owner) { FactoryGirl.create(:user) }
         # before do 
           # login_as non_owner
           # visit facility_path(facility)
         # end 
#          
         # describe "should not see the edit and delete buttons" do
           # it { should_not have_link('Edit Facility') }
           # it { should_not have_link('Delete Facility') }
         # end 
# 
      # end
      
      describe "should show correct associations" do
        before { FactoryGirl.create(:sample_set, owner: user, facility: facility, num_samples: 20 ) }
        
        describe "when showing the samples belonging to this facility" do
          let!(:first_sample_id) { facility.samples.first.id }
          let!(:last_sample_id) { facility.samples.last.id }
          before { visit facility_path(facility) }
          it { should have_content('Samples associated with this facility') }
          it { should have_selector('table tr th', text: 'Sample ID') } 
          it { should have_selector('table tr td', text: first_sample_id) } 
          it { should have_selector('table tr td', text: last_sample_id) } 
        end
        
        describe "when showing the sample sets belonging to this facility" do
          let!(:first_sample_set_id) { facility.sample_sets.first.id }
          let!(:last_sample_set_id) { facility.sample_sets.last.id }
          before { visit facility_path(facility) }
          it { should have_content('Sample Sets associated with this facility') }
          it { should have_selector('table tr th', text: 'Sample Set ID') } 
          it { should have_selector('table tr td', text: first_sample_set_id) } 
          it { should have_selector('table tr td', text: last_sample_set_id) } 
        end
      
      end
    
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit facility_path(facility) }
        it { should have_title('Sign in') }
        # it { should_not have_link('Edit Facility') }
        # it { should_not have_link('Delete Facility') }
      end
    end
    
  end
  
  
  # describe "facility destruction" do
    # let!(:facility_empty) { FactoryGirl.create(:facility, contact: user, code: 'FAC-empty') }
    # let!(:facility_with_content) { FactoryGirl.create(:facility, contact: user, code: 'FAC-full') }
    # let!(:sample) { FactoryGirl.create(:sample, owner: user, 
                                                # facility: facility_with_content,
                                                # ) }      
# 
    # describe "as correct user" do
      # before { login_as user }
#       
      # describe "of a facility with no content" do
        # before { visit facility_path(facility_empty) }
# 
        # it "should delete" do
          # expect { click_link "Delete Facility" }.to change(Facility, :count).by(-1)
        # end
      # end
#       
      # describe "of a facility with content" do
        # before { visit facility_path(facility_with_content) }
# 
        # it "should not delete" do
          # expect { click_link "Delete Facility" }.not_to change(Facility, :count)
        # end
        # describe "should display an error message" do
          # before { click_link "Delete Facility" }
          # let!(:error_message) {"Unable to delete a Facility that contains samples and/or sample sets."}
#           
          # it { should have_content(error_message) }
        # end
      # end
#       
    # end
  # end
#   
#   
  # describe "edit page" do
#     
    # let!(:facility) { FactoryGirl.create(:facility, contact: user, code: 'WTC') }
#     
    # describe "for signed-in users" do
#     
      # before { login_as user }
      # before { visit edit_facility_path(facility) }
#       
      # it { should have_content('Edit Facility ' + facility.code) }
      # it { should have_title(full_title('Edit Facility')) }
      # it { should_not have_title('| Home') }
#       
      # describe "with invalid information" do
#         
          # before do
            # fill_in 'facility_code', with: ''
            # click_button "Update"
          # end
#           
          # describe "should return an error" do
            # it { should have_content('error') }
          # end
#   
      # end
#   
      # describe "with valid information" do
#   
        # before do
          # fill_in 'facility_code'  , with: 'CUP'
          # fill_in 'facility_description'   , with: 'A new description'
        # end
#         
        # it "should update, not add a facility" do
          # expect { click_button "Update" }.not_to change(Facility, :count).by(1)
        # end
#         
        # describe "should return to view page" do
          # before { click_button "Update" }
          # it { should have_content('Facility updated') }
          # it { should have_title(full_title('Facility View')) }
        # end
#       
      # end
#       
    # end
#     
    # describe "for non signed-in users" do
      # describe "should be redirected back to signin" do
        # before { visit edit_facility_path(facility) }
        # it { should have_title('Sign in') }
      # end
    # end
  # end
  
end