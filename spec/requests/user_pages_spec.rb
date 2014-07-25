require 'spec_helper'

describe "User pages" do

  subject { page }
  
  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.firstname)
        end
      end
    end
    
    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:sample_set, owner: user, num_samples: 60) }
    let!(:m2) { FactoryGirl.create(:sample_set, owner: user, num_samples: 50) }
    
    before do
      sign_in user
      visit user_path(user)
    end

    it { should have_content(user.firstname) }
    it { should have_title(user.firstname) }
    
    describe "sample_sets" do
      it { should have_content(m1.num_samples) }
      it { should have_content(m2.num_samples) }
      it { should have_content(user.sample_sets.count) }
    end
  end

  describe "signup page" do
    before { visit register_path }

    it { should have_content('Register') }
    it { should have_title(full_title('Register')) }
  end
  
  describe "register page" do

    before { visit register_path }

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
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }
               
        it { should have_link('Sign out') }
        it { should have_content('Dashboard for '+user.firstname) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end      
    end        
               
    describe "edit" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit edit_user_path(user)
      end

      describe "page" do
        it { should have_content("Update your profile") }
        it { should have_title("Edit user") }
      end

      describe "with invalid information" do
        before { click_button "Save changes" }

        it { should have_content('error') }
      end
      
      describe "with valid information" do
        let(:new_firstname)  { "Firstname2" }
        let(:new_surname)  { "Surname2" }
        let(:new_email) { "new@example.com" }
        before do
          fill_in "Firstname",        with: new_firstname
          fill_in "Surname",          with: new_surname
          fill_in "Email",            with: new_email
          fill_in "Password",         with: user.password
          fill_in "Confirm Password", with: user.password
          click_button "Save changes"
        end

        it { should have_title(new_firstname) }
        it { should have_selector('div.alert.alert-success') }
        it { should have_link('Sign out', href: signout_path) }
        specify { expect(user.reload.firstname).to  eq new_firstname }
        specify { expect(user.reload.email).to eq new_email }
      end
    end
  end
end