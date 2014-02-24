require 'spec_helper'

describe "SampleSet pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "sample_set creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a sample_set" do
        expect { click_button "Submit" }.not_to change(SampleSet, :count)
      end

      describe "error messages" do
        before { click_button "Submit" }
        it { should have_content('error') }
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
  
  describe "sample_set destruction" do
    before { FactoryGirl.create(:sample_set, owner: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a sample_set" do
        expect { click_link "delete" }.to change(SampleSet, :count).by(-1)
      end
    end
  end
end