require 'spec_helper'


describe "Sample pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }


  describe "Show page" do
    
    let!(:sample) { FactoryGirl.create(:sample, owner: user, facility_id: 5) }
        
    describe "for signed-in users" do
      
      before { sign_in user }
      before { visit sample_path(sample) }
      
      let!(:page_heading) {"Sample " + sample.id.to_s}
      
      it { should have_selector('h1', :text => page_heading) }
      it { should have_title(full_title('Sample View')) }
      it { should_not have_title('| Home') }  
      it { should have_button('Edit Sample') }
      it { should have_button('Delete Sample') }
      
      # describe "when clicking the edit button" do
        # before { click_button "Edit Sample" }
        # let!(:page_heading) {"Edit Sample " + sample.id.to_s}
#         
        # describe 'should have a page heading for editing the correct sample set' do
          # it { should have_content(page_heading) }
        # end
      # end
      
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
  

end