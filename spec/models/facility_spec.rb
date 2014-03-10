require 'spec_helper'

describe Facility do

  let(:contact) { FactoryGirl.create(:user) }
  before { @facility = contact.facilities.build(code:"FACE", description: "Lorem ipsum") }

  subject { @facility }

  it { should respond_to(:code) }
  it { should respond_to(:contact_id) }
  it { should respond_to(:description) }
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
end