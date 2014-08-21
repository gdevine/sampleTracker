require 'spec_helper'


describe "User pages" do

  subject { page }
  
  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      sign_in(user)
      visit users_path
    end

    it { should have_title('User List') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('td', text: user.firstname)
        end
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
    let!(:m2) { FactoryGirl.create(:sample_set, owner: user, num_samples: 50) }
    
    before do
      sign_in(user)
      visit user_path(user)
    end

    it { should have_content(user.firstname) }
    it { should have_title(user.firstname) }

  end

  describe "signup page" do
    before { visit new_user_registration_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end
  
  describe "register page" do

    before { visit new_user_registration_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "First Name",    with: "Example"
        fill_in "Surname",      with: "Bla"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobarbar"
        fill_in "Confirm Password", with: "foobarbar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }
               
        it { should have_link('Sign in') }  # As the account has not been approved yet therefore unable to log in
        it { should have_content('HIE Sample Tracker') }
        it { should have_selector('div.alert.alert-notice', text: 'You have signed up successfully but your account has not been approved by your administrator yet') }
      end      
    end        
               
  end
end