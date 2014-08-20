require 'spec_helper'

describe "sample_set pages:" do

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
      end
      
      describe "with sample sets in the system" do
        before do
          FactoryGirl.create(:sample_set, owner: user)
          FactoryGirl.create(:sample_set, owner: user)
          visit sample_sets_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Facility')
        end
                   
        it "should list each sample_set" do
          SampleSet.paginate(page: 1).each do |ss|
            expect(page).to have_selector('table tr td', text: ss.facility_id)
          end
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
      
      let!(:myfacility) { FactoryGirl.create(:facility, contact: user, description: 'a new description') } 
      let!(:myproject) { FactoryGirl.create(:project) } 
      before { sign_in user }
      before { visit new_sample_set_path }            
      
      it { should have_content('New Sample Set') }
      it { should have_content('MYFAC_') }
      it { should have_title(full_title('New Sample Set')) }
      it { should_not have_title('| Home') }
      it { should have_selector('#facilities') }
      
      describe "with invalid information" do
        
        it "should not create a sample_set" do
          expect { click_button "Submit" }.not_to change(SampleSet, :count)
        end
                
        before do
          click_button "Submit"
        end
        describe "should return an error" do
          it { should have_content('error') }
        end
        
      end
      
      
      describe "with 0 requested samples" do
        
        let(:numsamples) { 0 }
        before do
          find('#facilities').find(:xpath, 'option['+(myfacility.id + 1).to_s+']', visible: false).select_option
          find('#projects').find(:xpath, 'option['+(myproject.id + 1).to_s+']', visible: false).select_option
          fill_in 'sample_set_num_samples'  , with: numsamples
          fill_in 'sample_set_sampling_date', with: Date.new(2012, 12, 3)
        end
        
        it "should not create a sample_set" do
          expect { click_button "Submit" }.not_to change(SampleSet, :count)
        end
      end
  
  
      describe "with valid information" do
        
        let(:numsamples) { 50 }
        before do
          find('#facilities').find(:xpath, 'option['+(myfacility.id + 1).to_s+']', visible: false).select_option
          find('#projects').find(:xpath, 'option['+(myproject.id + 1).to_s+']', visible: false).select_option
          fill_in 'sample_set_num_samples'  , with: numsamples
          fill_in 'sample_set_sampling_date', with: Date.new(2012, 12, 3)
        end
        
        it "should create a sample_set" do
          expect { click_button "Submit" }.to change(SampleSet, :count).by(1)
        end
        
        it "should create the correct number of new samples based on sample_set" do
          expect { click_button "Submit" }.to change(Sample, :count).by(numsamples)
        end
        
        describe "should return to view page" do
          before { click_button "Submit" }
          it { should have_content('Sample Set created!') }
          it { should have_title(full_title('Sample Set View')) }
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
    let!(:sample_set) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }

    describe "as correct user" do
      before do
        sign_in user
        visit sample_set_path(sample_set)
      end
      
      describe "of a Sample Set with no completed Samples" do
        it "should delete a sample_set" do
          expect { click_link "Delete Sample Set" }.to change(SampleSet, :count).by(-1)
        end
      end
      
      describe "of a Sample Set with completed Samples" do
        let!(:sample) { FactoryGirl.create(:sample, owner: user, 
                                                sample_set_id: sample_set.id,
                                                sampled: true
                                                ) } 
                                                
        before { visit sample_set_path(sample_set) }
        
        it "should not delete" do
          expect { click_link "Delete Sample Set" }.not_to change(SampleSet, :count)
        end
        
        describe "should display an error message" do
          before { click_link "Delete Sample Set" }
          let!(:error_message) {"Can not delete a Sample Set that contains Samples marked as complete"}
          it { should have_content(error_message) }
        end
        
      end
      
    end
  end
  
  
  describe "Show page" do
    
    let!(:sample_set) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit sample_set_path(sample_set) }
      
      let!(:page_heading) {"Sample Set " + sample_set.id.to_s}
      
      it { should have_selector('h2', :text => page_heading) }
      it { should have_title(full_title('Sample Set View')) }
      it { should_not have_title('| Home') }  
      
      it { should have_link('Options') }
      it { should have_link('Edit Sample Set') }
      it { should have_link('Delete Sample Set') }    
      it { should have_link('Append New Sample') }
      it { should have_link('Export CSV') }
      it { should have_link('Print QR codes') }
      
      
      describe "when clicking the edit link" do
        before { click_link "Edit Sample Set" }
        let!(:page_heading) {"Edit Sample Set " + sample_set.id.to_s}
        
        describe 'should have a page heading for editing the correct sample set' do
          it { should have_content(page_heading) }
        end
      end
      
      describe "clicking the append new sample link" do
        let!(:page_heading) {"Sample Set " + sample_set.id.to_s}
        describe 'should return to the sample set index page (with newly added sample)' do
          before {click_link "Append New Sample"}
          it { should have_content(page_heading) }
        end
      end
        
      describe "appending a sample" do
        before do
          visit sample_set_path(sample_set)
        end
        it "should add 1 to the num_samples within a sample set" do
          expect { click_link "Append New Sample" }.to change(Sample, :count).by(1)
        end
      end
      
      describe "appending a sample" do
        let!(:num_samples_old) { sample_set.num_samples }
        it "should add 1 to number of samples within a sample set" do
          click_link "Append New Sample"
          num_samples_old.should == sample_set.reload.num_samples-1
        end
      end
      
      describe "should show the samples belonging to this sample set" do
        
        let!(:first_sample_id) { sample_set.samples.first.id }
        let!(:last_sample_id) { sample_set.samples.last.id }
        before { visit sample_set_path(sample_set) }
        it { should have_content('Samples included in this sample set') }
        it { should have_selector('table tr th', text: 'Sample ID') } 
        it { should have_selector('table tr td', text: first_sample_id) } 
        it { should have_selector('table tr td', text: last_sample_id) } 
      end
      
    end
    
    describe "who don't own the current sample set" do
       let(:non_owner) { FactoryGirl.create(:user) }
       before do 
         sign_in(non_owner)
         visit sample_set_path(sample_set)
       end 
       
       describe "should not see the edit and delete links" do
         it { should_not have_link('Options') }
         it { should_not have_link('Edit Sample Set') }
         it { should_not have_link('Append New Sample') }
         it { should_not have_link('Delete Sample Set') }
       end 
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit sample_set_path(sample_set) }
        it { should have_title('Sign in') }
        it { should_not have_link('Edit Sample Set') }
        it { should_not have_link('Delete Sample Set') }
      end
    end
    
  end


  describe "edit page" do
    
    let!(:sample_set) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
    
    describe "for signed-in users" do
    
      before { sign_in user }
      let!(:myfacility) { sample_set.facility }
      let!(:myproject) { sample_set.project }
      before { visit edit_sample_set_path(sample_set) }
      
      it { should have_content('Edit Sample Set ' + sample_set.id.to_s) }
      it { should have_title(full_title('Edit Sample Set')) }
      it { should_not have_title('| Home') }
      it { should_not have_selector('#sample_set_num_samples') }
      
      describe "with invalid information" do
        
          before do
            find('#facilities').find(:xpath, "option[1]").select_option
            click_button "Update"
          end
          
          describe "should return an error" do
            it { should have_content('error') }
          end
  
      end
  
      describe "with valid information" do
  
        before do
          find('#facilities').find(:xpath, 'option['+(myfacility.id + 1).to_s+']', visible: false).select_option
          find('#projects').find(:xpath, 'option['+(myproject.id + 1).to_s+']', visible: false).select_option
          fill_in 'sample_set_sampling_date', with: Date.new(2012, 12, 6)
        end
        
        it "should update, not add a sample_set" do
          expect { click_button "Update" }.not_to change(SampleSet, :count).by(1)
        end
        
        describe "should return to view page" do
          before { click_button "Update" }
          it { should have_content('Sample Set updated') }
        end
      
      end
      
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit edit_sample_set_path(sample_set) }
        it { should have_title('Sign in') }
      end
    end
  end

end