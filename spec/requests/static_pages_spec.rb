require 'spec_helper'

describe "Static pages" do
  
  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('HIE Sample Tracker') }
    it { should have_title(full_title('')) }
    it { should_not have_title('| Home') }
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:sample_set, owner: user, project_id: 3)
        FactoryGirl.create(:sample_set, owner: user, project_id: 4)
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.project_id)
        end
      end
    end
    
  end
  
    
  describe "Help page" do
    before { visit help_path }

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
