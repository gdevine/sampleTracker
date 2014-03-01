require 'spec_helper'

describe "SampleSet pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }

  describe "Index page" do
    
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit sample_sets_path }
      
      it { should have_content('Sample Set List') }
      it { should have_title(full_title('Sample Set List')) }
      it { should_not have_title('| Home') }
      
      describe "with no sample sets in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Sample Sets found')
        end
        
        it "should still have a create new button " do
          expect(page).to have_button('New Sample Set')
        end
      end
      
      describe "with sample sets in the system" do
        before do
          FactoryGirl.create(:sample_set, owner: user, project_id: 3)
          FactoryGirl.create(:sample_set, owner: user, project_id: 4)
          #sign_in user
          visit sample_sets_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Sample Set ID')
        end
                   
        it "should list each sample_set" do
          SampleSet.paginate(page: 1).each do |ss|
            expect(page).to have_selector('table tr td', text: ss.id)
          end
        end
        
        it "should have a create new button " do
          expect(page).to have_button('New Sample Set')
        end
      end
      
      describe "clicking the new sample set button" do
        before do
          click_button "New Sample Set"
        end

        it "should open up the create sample set page" do
          expect(page).to have_title('New Sample Set')
        end
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit sample_sets_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  

  describe "New page" do
    
    describe "for signed-in users" do
    
      before { sign_in user }
      before { visit new_sample_set_path }
      
      it { should have_content('New Sample Set') }
      it { should have_title(full_title('New Sample Set')) }
      it { should_not have_title('| Home') }
      
      describe "with invalid information" do
  
        it "should not create a sample_set" do
          expect { click_button "Submit" }.not_to change(SampleSet, :count)
        end
  
      end
  
      describe "with valid information" do
  
        before do
          fill_in 'sample_set_facility_id'  , with: 1 
          fill_in 'sample_set_project_id'   , with: 1
          fill_in 'sample_set_num_samples'  , with: 50
          fill_in 'sample_set_sampling_date', with: Date.new(2012, 12, 3)
        end
        
        it "should create a sample_set" do
          expect { click_button "Submit" }.to change(SampleSet, :count).by(1)
        end
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit new_sample_set_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "sample_set destruction" do
    before { FactoryGirl.create(:sample_set, owner: user) }

    describe "as correct user" do
      before { sign_in user }
      before { visit sample_sets_path }

      it "should delete a sample_set" do
        expect { click_link "delete" }.to change(SampleSet, :count).by(-1)
      end
    end
  end
  
  describe "Show page" do
    
    let!(:sampleset) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit sample_set_path(sampleset) }
      
      it { should have_content('Sample Set View') }
      it { should have_title(full_title('Sample Set View')) }
      it { should_not have_title('| Home') }
    end
  end
  
end