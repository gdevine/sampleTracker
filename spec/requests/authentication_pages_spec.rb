require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit new_user_session_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
    
    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-alert') }
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
      end

      it { should have_content('Welcome to the HIE Sample Tracker') }
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Sign out',    href: destroy_user_session_path) }
      it { should_not have_link('Sign in', href: new_user_session_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
    
  end

end
