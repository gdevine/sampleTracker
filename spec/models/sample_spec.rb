require 'spec_helper'

describe Sample do

  let(:owner) { FactoryGirl.create(:user) }
  before { @sample = owner.samples.build(facility: FactoryGirl.create(:facility), 
                                         project_id: 1, 
                                         sample_set_id: 1,
                                         is_primary: true, 
                                         sampled: false) }

  subject { @sample }
  
  it { should respond_to( :owner_id ) }
  it { should respond_to( :sample_set_id ) }
  it { should respond_to( :parent_id ) }
  it { should respond_to( :sampled ) }
  it { should respond_to( :date_sampled ) }
  it { should respond_to( :storage_location) }
  it { should respond_to( :facility_id ) }
  it { should respond_to( :storage_location_id ) }
  it { should respond_to( :project_id  ) }
  it { should respond_to( :comments ) }
  it { should respond_to( :is_primary ) }
  it { should respond_to( :ring ) }
  it { should respond_to( :tree ) }
  it { should respond_to( :plot ) }
  it { should respond_to( :northing ) }
  it { should respond_to( :easting  ) }
  it { should respond_to( :vertical ) }
  it { should respond_to( :material_type ) }
  it { should respond_to( :amount_collected ) }
  it { should respond_to( :amount_stored ) }
  it { should respond_to( :facility ) }
  it { should respond_to( :owner ) }
  it { should respond_to( :subsamples ) }
  
  
  its(:owner) { should eq owner }

  it { should be_valid }

  describe "when owner_id is not present" do
    before { @sample.owner_id = nil }
    it { should_not be_valid }
  end
  
  describe "when facility_id is not present" do
    before { @sample.facility_id = nil }
    it { should_not be_valid }
  end
  
  describe "when project_id is not present" do
    before { @sample.project_id = nil }
    it { should_not be_valid }
  end
  
  describe "when it is part of a sample set" do
    its(:is_primary) { should eql true } 
  end
  
  describe "when a 'sampled' sample does not have a storage_location" do
    before do 
      @sample.storage_location_id = ""
      @sample.sampled = true
    end
    
    it { should_not be_valid }
  end
  
  describe "when a 'sampled' sample does not have a date_sampled" do
    before do 
      @sample.storage_location_id = 1
      @sample.plot = 3
      @sample.tree = 4
      @sample.ring = 4
      @sample.date_sampled = ""
      @sample.sampled = true
    end
    
    it { should_not be_valid }
  end
  
  describe "when a 'sampled' sample does not correct facility-based fields completed" do
    before do 
      @sample.storage_location_id = 1
      @sample.plot = ''
      @sample.tree = 4
      @sample.ring = 4
      @sample.sampled = true
    end
    
    it { should_not be_valid }
  end
  
  
  
end