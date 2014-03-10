require 'spec_helper'

describe SampleSet do

  let(:owner) { FactoryGirl.create(:user) }
  before do
    @sample_set = owner.sample_sets.build(sampling_date: Date.new(2012, 12, 3), facility_id: 1, project_id: 1, num_samples: 50)
  end
  
  subject { @sample_set }
  
  it { should respond_to(:id) }
  it { should respond_to(:owner_id) }
  it { should respond_to(:facility_id) }
  it { should respond_to(:project_id) }
  it { should respond_to(:num_samples) }
  it { should respond_to(:sampling_date) }
  it { should respond_to(:owner) }
  it { should respond_to(:status) }
  it { should respond_to(:add_info) }
  it { should respond_to(:samples) }
  
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
    before { @sample_set.num_samples = 1000 }
    it { should_not be_valid }
  end
  
  describe "test that the correct number of samples are generated upon sample set creation" do    
    before do
      @sample_set.save
    end
    
    let(:mycount) { @sample_set.samples.to_a.count } 
    its(:num_samples) { should eql mycount }   
  end
  
  describe "test that a sample_set and sample_set sample member have the same owner" do
    before do
      @sample_set.save
    end
    
    let(:first_sample_owner) { @sample_set.samples.first.owner } 
    let(:last_sample_owner) { @sample_set.samples.last.owner } 
    
    its(:owner) { should eql first_sample_owner } 
    its(:owner) { should eql last_sample_owner } 
  end
  
end