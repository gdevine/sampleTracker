require 'spec_helper'

describe Sample do

  let(:owner) { FactoryGirl.create(:user) }
  let(:container) { FactoryGirl.create(:container) }
  before { @sample = owner.samples.build(facility: FactoryGirl.create(:facility), 
                                         date_sampled: Date.new(2013, 11, 7),
                                         container: container,  
                                         storage_location: container.storage_location,
                                         project: FactoryGirl.create(:project), 
                                         ring: 3,           
                                         tree: 4,           
                                         plot: 6,    
                                         sample_set_id: 1,
                                         amount_collected: '40g',
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
  it { should respond_to( :container_id ) }
  it { should respond_to( :container ) }
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
  it { should respond_to( :project ) }
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
  
  describe "when is_primary is not present" do
    before { @sample.is_primary = '' }
    it { should_not be_valid }
  end
  
  describe "when it is part of a sample set" do
    its(:is_primary) { should eql true } 
  end
  
  describe "when a 'sampled' sample does not have a storage_location" do
    before do 
      @sample.container_id = nil
      @sample.storage_location_id = nil
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
  
  describe "when a subsample with parent_id is marked as is_primary" do
    before do 
      @sample.parent_id = 3
      @sample.is_primary = true
    end
    
    it { should_not be_valid }
  end
  
  describe "when a subsample doesn't have a parent_id" do
    before do 
      @sample.is_primary = false
      @sample.parent_id = ''
    end
    
    it { should_not be_valid }
  end
  
  describe "when a sample's storage location is not the same as the location of a container it is housed in" do
    let!(:loc1) { FactoryGirl.create(:storage_location, code:'LOC1') }
    let!(:loc2) { FactoryGirl.create(:storage_location, code:'LOC2') }
    
    before do
      @sample.save
      @sample.sampled = true
      @sample.storage_location_id = loc1.id
      @sample.container.storage_location_id = loc2.id      
    end
    
    it { should_not be_valid }
  end
  
  describe "when a subsample's facility is not the same as its parent" do
    let!(:newfacility) { FactoryGirl.create(:facility) }                     
    let!(:parent_sample) { FactoryGirl.create(:sample, owner: owner, sampled: true, facility_id: newfacility.id, is_primary:true ) }  
   
    before do
      @sample.sampled = true
      @sample.parent_id = parent_sample.id
      @sample.is_primary = false
    end 
    
    it { should_not be_valid }
    
  end
  
  describe "associated analyses" do
    let(:analysis1) { FactoryGirl.create(:analysis) }
    let(:analysis2) { FactoryGirl.create(:analysis) }
    
    before do 
      @sample.analyses << analysis1
      @sample.analyses << analysis2
      @sample.save
    end
    
    it "should have the right number of analyses" do
      expect(@sample.analyses.count).to eql 2
    end
    
    it "associated analysis should have the right number of samples" do
      expect(analysis1.samples.count).to eql 1
      expect(analysis2.samples.count).to eql 1
    end
  end
  
  
end