require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the content 'HIE Sample Tracker'" do
      visit '/static_pages/home'
      expect(page).to have_content('HIE Sample Tracker')
    end
    
    it "should have the base title" do
      visit '/static_pages/home'
      expect(page).to have_title("HIE Sample Tracker")
    end

    it "should not have a custom page title" do
      visit '/static_pages/home'
      expect(page).not_to have_title('| Home')
    end
    
    
  end
  
  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
    
    it "should have the right title" do
      visit '/static_pages/help'
      expect(page).to have_title("HIE Sample Tracker | Help")
    end
  end
  
  describe "About page" do

    it "should have the content 'About the HIE Sample Tracker'" do
      visit '/static_pages/about'
      expect(page).to have_content('About the HIE Sample Tracker')
    end
    
    it "should have the right title" do
      visit '/static_pages/about'
      expect(page).to have_title("HIE Sample Tracker | About")
    end
  end
  
end
