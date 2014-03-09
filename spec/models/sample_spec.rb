require 'spec_helper'

describe Sample do

  let(:owner) { FactoryGirl.create(:user) }
  # @sample = owner.samples.build(facility_id: 1, sampled: false, owner_id: user.id)
  before { @sample = owner.samples.build(date_sampled: Date.new(2012, 12, 3), 
                                         facility_id: 1, 
                                         project_id: 1, 
                                         sample_set_id: 1, 
                                         sampled: true,
                                         tree: 3) }

  subject { @sample }
  
  it { should respond_to( :owner_id        ) }
  it { should respond_to( :sample_set_id   ) }
  it { should respond_to( :sampled         ) }
  it { should respond_to( :date_sampled    ) }
  it { should respond_to( :storage_location) }
  it { should respond_to( :facility_id     ) }
  it { should respond_to( :project_id      ) }
  it { should respond_to( :comments        ) }
  it { should respond_to( :is_primary      ) }
  it { should respond_to( :ring            ) }
  it { should respond_to( :tree            ) }
  it { should respond_to( :plot            ) }
  it { should respond_to( :northing        ) }
  it { should respond_to( :easting         ) }
  it { should respond_to( :vertical        ) }
  it { should respond_to( :material_type   ) }
  it { should respond_to( :amount_collected) }
  it { should respond_to( :amount_stored   ) }
  
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
  
  describe "when date_sampled is not present" do
    before { @sample.date_sampled = nil }
    it { should_not be_valid }
  end
  
end
