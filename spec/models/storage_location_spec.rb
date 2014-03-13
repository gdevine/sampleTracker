require 'spec_helper'

describe Facility do
  
  let(:custodian) { FactoryGirl.create(:user) }
  before { @storage_location = custodian.storage_locations.build(code: "HIE-L9R32", 
                                                                address: "Room 32, Building L9, HIE, UWS, Richmond", 
                                                                building: "L9", 
                                                                room: 32, 
                                                                custodian_id: custodian.id, 
                                                                description: "this is a shelf at the back of the room") }

  subject { @storage_location }

  it { should respond_to(:code) }
  it { should respond_to(:custodian_id) }
  it { should respond_to(:building) }
  it { should respond_to(:room) }
  it { should respond_to(:address) }
  it { should respond_to(:description) }
  it { should respond_to(:custodian) }
  it { should respond_to(:samples) }
  
  its(:custodian) { should eq custodian}
  
  it { should be_valid }
  
  describe "when custodian_id is not present" do
    before { @storage_location.custodian_id = nil }
    it { should_not be_valid }
  end
  
  describe "when code is not present" do
    before { @storage_location.code = nil }
    it { should_not be_valid }
  end
  
  describe "when address is not present" do
    before { @storage_location.address = nil }
    it { should_not be_valid }
  end

  describe "with a storage location code that is too long" do
    before { @storage_location.code = "a" * 12 }
    it { should_not be_valid }
  end  
  
  describe "when storage location code is already taken" do
    before do
      storage_location_with_same_code = @storage_location.dup
      storage_location_with_same_code.save
    end

    it { should_not be_valid }
  end
  
  describe "sample associations" do

    before { @storage_location.save }
    let!(:older_sample) do
      FactoryGirl.create(:sample, owner: custodian, storage_location: @storage_location, created_at: 1.day.ago)
    end
    let!(:newer_sample) do
      FactoryGirl.create(:sample, owner: custodian, storage_location: @storage_location, created_at: 1.hour.ago)
    end

    it "should have the right samples in the right order" do
      expect(@storage_location.samples.to_a).to eq [newer_sample, older_sample]
    end
    
  end
 
 
end