require 'spec_helper'

describe "Static pages:" do
  
  subject { page }

  describe "Dashboard page" do
    
    describe "for signed-in users" do
      
      let(:user) { FactoryGirl.create(:user) }
      
      describe "with no sample sets" do
        before do
          sign_in user
          visit dashboard_path
        end
        
        it "should have an information message" do
          expect(page).to have_content('No Sample Sets found')
        end
        
      end
      
      describe "with sample sets" do
      
        before do
          FactoryGirl.create(:sample_set, owner: user, project_id: 3)
          FactoryGirl.create(:sample_set, owner: user, project_id: 4)
          sign_in user
          visit dashboard_path
        end
        
        
        it "should have correct table heading" do
          expect(page).to have_selector('th', text: 'Sample Set ID')
        end
                
        it "should contain each in a table row" do
          user.my_sample_sets.each do |item|
            expect(page).to have_selector('table tr td', text: item.id)
          end
        end
      end
    
      describe "with no samples" do
        before do
          sign_in user
          visit dashboard_path
        end
        
        it "should have an information message" do
          expect(page).to have_content('No Samples found')
        end
        
      end
      
      describe "with sample sets" do
      
        before do
          FactoryGirl.create(:sample, owner: user)
          FactoryGirl.create(:sample, owner: user)
          sign_in user
          visit dashboard_path
        end
        
        it "should have correct table heading" do
          expect(page).to have_selector('th', text: 'Sample ID')
        end
                
        it "should contain each in a table row" do
          user.my_samples.each do |item|
            expect(page).to have_selector('table tr td', text: item.id)
          end
        end
        
      end
      
    end
  
  end
    
  describe "Home page" do
    before { visit root_path }
    
    it { should have_title(full_title('Home')) }
  end
    
  describe "Help page when not logged in" do
    before { visit help_path }
    it { should have_title('Sign in') }
  end
  
  describe "Help page whilst logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit help_path
    end

    it { should have_content('Help') }
    it { should have_title(full_title('Help')) }
  end
  
  
  describe "About page" do
    before { visit about_path }

    it { should have_content('About the HIE Sample Tracker') }
    it { should have_title(full_title('About')) }
  end
  
  
  describe "Contact page" do
    before { visit contact_path }

    it { should have_content('Contact') }
    it { should have_title(full_title('Contact')) }
  end
  
end
