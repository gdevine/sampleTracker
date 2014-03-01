require 'spec_helper'

describe "Menu Panel:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  # The menu bar should only appear on the home page when signed in
  describe "Home page" do
    describe "for signed-in users" do
      before do 
        sign_in user 
        visit root_path
      end
        
      it 'should have a nav#minibar bar' do
        expect(page).to have_selector('nav#minibar')
      end
    end
    
    describe "for non signed-in users" do
      before { visit root_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector('nav#minibar')
      end
    end
  end
  
  # The menu bar shouldn't appear on the standard satic pages: contact page, help page etc
  describe "Help page" do
    describe "for signed-in users" do
      before { sign_in user }
      before { visit help_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector('nav#minibar')
      end
    end
    
    describe "for non signed-in users" do
      before { visit help_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector('nav#minibar')
      end
    end
  end
  
  describe "About page" do
    describe "for signed-in users" do
      before { sign_in user }
      before { visit about_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector("nav#minibar")
      end
    end
    
    describe "for non signed-in users" do
      before { visit about_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector("nav#minibar")
      end
    end
  end
  
  describe "Contact page" do
    describe "for signed-in users" do
      before { sign_in user }
      before { visit contact_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector('nav#minibar')
      end
    end
    
    describe "for non signed-in users" do
      before { visit contact_path }
      it 'should not have a nav#minibar bar' do
        expect(page).not_to have_selector('nav#minibar')
      end
    end
  end
  
  # The menu bar should not appear on sign-in or register error pages
  describe "Sign in error page" do
    before { visit signin_path }
    before { click_button "Sign in" }

    it 'should not have a nav#minibar bar' do
      expect(page).not_to have_selector('nav#minibar')
    end
  end
  
  describe "Register error page" do
    before { visit register_path }
    before { click_button "Create my account" }

    it 'should not have a nav#minibar bar' do
      expect(page).not_to have_selector('nav#minibar')
    end
  end

end