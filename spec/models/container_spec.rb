require 'spec_helper'

describe Container do
  let(:owner) { FactoryGirl.create(:user) }
  
  before do 
    @container = owner.containers.build(container_type: "box", description: "Lorem ipsum", storage_location_id: 1) 
  end

  subject { @container }

  it { should respond_to(:container_type) }
  it { should respond_to(:owner_id) }
  it { should respond_to(:owner) }
  it { should respond_to(:storage_location_id) }
  it { should respond_to(:storage_location) }
  it { should respond_to(:description) }
  it { should respond_to(:samples) }
  
  its(:owner) { should eq owner}
  
  it { should be_valid }
  
  describe "when owner_id is not present" do
    before { @container.owner_id = nil }
    it { should_not be_valid }
  end
  
  describe "when storage location id is not present" do
    before { @container.storage_location_id = nil }
    it { should_not be_valid }
  end
  
  describe "sample associations" do

    before { @container.save }
    let!(:older_sample) do
      FactoryGirl.create(:sample, owner: owner, container: @container, storage_location_id: @container.storage_location_id, created_at: 1.day.ago)
    end
    let!(:newer_sample) do
      FactoryGirl.create(:sample, owner: owner, container: @container, storage_location_id: @container.storage_location_id, created_at: 1.hour.ago)
    end

    it "should have the right samples in the right order" do
      expect(@container.samples.to_a).to eq [newer_sample, older_sample]
    end
    
  end
  
end
