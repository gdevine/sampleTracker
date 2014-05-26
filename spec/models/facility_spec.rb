require 'spec_helper'

describe Facility do

  let(:contact) { FactoryGirl.create(:user) }
  before { @facility = contact.facilities.build(contact: contact, code:"FACE3", description: "Lorem ipsum") }
  
  subject { @facility }

  it { should respond_to(:code) }
  it { should respond_to(:contact_id) }
  it { should respond_to(:description) }
  it { should respond_to(:sample_sets) }
  it { should respond_to(:samples) }
  
  its(:contact) { should eq contact }
  
  it { should be_valid }

  describe "when contact_id is not present" do
    before { @facility.contact_id = nil }
    it { should_not be_valid }
  end
  
  describe "when code is not present" do
    before { @facility.code = nil }
    it { should_not be_valid }
  end
  
  describe "with blank description" do
    before { @facility.description = " " }
    it { should_not be_valid }
  end

  describe "with a code that is too long" do
    before { @facility.code = "a" * 12 }
    it { should_not be_valid }
  end  
  
  describe "when facility code is already taken" do
    before do
      facility_with_same_code = @facility.dup
      facility_with_same_code.save
    end

    it { should_not be_valid }
  end
  
  
  describe "sample_set associations" do
    before { @facility.save }
    let!(:older_sample_set) do
      FactoryGirl.create(:sample_set, owner: contact, facility: @facility, created_at: 1.day.ago)
    end
    let!(:newer_sample_set) do
      FactoryGirl.create(:sample_set, owner: contact, facility: @facility, created_at: 1.hour.ago)
    end

    it "should have the right sample_sets in the right order" do
      expect(@facility.sample_sets.to_a).to eq [newer_sample_set, older_sample_set]
    end
        
    describe "status" do
      let(:unowned_sample_set) do
        FactoryGirl.create(:sample_set, owner: FactoryGirl.create(:user))
      end
      its(:sample_sets) { should include(newer_sample_set) }
      its(:sample_sets) { should include(older_sample_set) }
      its(:sample_sets) { should_not include(unowned_sample_set) }
    end
    
  end
  
  
  describe "sample associations" do

    before { @facility.save }
    let!(:older_sample) do
      FactoryGirl.create(:sample, owner: contact, facility: @facility, created_at: 1.day.ago)
    end
    let!(:newer_sample) do
      FactoryGirl.create(:sample, owner: contact, facility: @facility, created_at: 1.hour.ago)
    end

    it "should have the right samples in the right order" do
      expect(@facility.samples.to_a).to eq [newer_sample, older_sample]
    end
    
  end
  
  describe "sample_sets and sample members" do
    before { @facility.save }
    let!(:sample_set) do
      FactoryGirl.create(:sample_set, owner: contact, facility: @facility, num_samples: 10, created_at: 1.day.ago)
    end
    
    it "should belong to the same facility" do
      expect(sample_set.samples.first.facility).to eql sample_set.facility
      expect(sample_set.samples.last.facility).to eql sample_set.facility
    end
    
  end
  
  
end