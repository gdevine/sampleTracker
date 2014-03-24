require 'spec_helper'

describe Sample do

  let(:owner) { FactoryGirl.create(:user) }
  before { @sample = owner.samples.build(date_sampled: Date.new(2012, 12, 3), 
                                         facility: FactoryGirl.create(:facility), 
                                         project_id: 1, 
                                         sample_set_id: 1, 
                                         sampled: true,
                                         tree: 3) }

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
  
  describe "when it is a subsample" do
    let(:parent) { FactoryGirl.create(:sample) }
    before do
      @sample.parent_id = parent.id
      @sample.save
    end
    it { should respond_to( :parent ) }
  end
  
  describe "when it has subsamples" do
    before do
      @sample.save
    end
    # let(:subsample) {FactoryGirl.create(:sample, facility: @sample.facility, parent:@sample)}
    let!(:older_subsample) {FactoryGirl.create(:sample, facility: @sample.facility, parent:@sample, created_at: 1.day.ago)}
    let!(:newer_subsample) {FactoryGirl.create(:sample, facility: @sample.facility, parent:@sample, created_at: 1.hour.ago)}
    
    it "should have the right subsamples in the right order" do
      expect(@sample.subsamples.to_a).to eq [newer_subsample, older_subsample]
    end
        
    its(:facility) { should eql older_subsample.facility } 
    its(:facility) { should eql newer_subsample.facility } 
    
  end
  
  
end
