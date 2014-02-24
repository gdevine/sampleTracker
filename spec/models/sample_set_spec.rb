require 'spec_helper'

describe SampleSet do

  let(:owner) { FactoryGirl.create(:user) }
  before { @sample_set = owner.sample_sets.build(sampling_date: Date.new(2012, 12, 3), facility_id: 1, project_id: 1, num_samples: 50) }
  
  subject { @sample_set }

  it { should respond_to(:owner_id) }
  it { should respond_to(:facility_id) }
  it { should respond_to(:project_id) }
  it { should respond_to(:num_samples) }
  it { should respond_to(:sampling_date) }
  it { should respond_to(:owner) }
  its(:owner) { should eq owner }
  
  
  it { should be_valid }

  describe "when owner_id is not present" do
    before { @sample_set.owner_id = nil }
    it { should_not be_valid }
  end

  describe "when facility_id is not present" do
    before { @sample_set.facility_id = nil }
    it { should_not be_valid }
  end
  
  describe "when project_id is not present" do
    before { @sample_set.project_id = nil }
    it { should_not be_valid }
  end
  
  describe "when sampling_date is not present" do
    before { @sample_set.sampling_date = nil }
    it { should_not be_valid }
  end
  
  describe "when num_samples is not present" do
    before { @sample_set.num_samples = nil }
    it { should_not be_valid }
  end
  
  describe "when num_samples is an unrealistically large number" do
    before { @sample_set.num_samples = 10000 }
    it { should_not be_valid }
  end
  
  
end