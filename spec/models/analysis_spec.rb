require 'spec_helper'

describe Analysis do
  before { @analysis = Analysis.new(code:"AN3", title:"Analysis type 3", description: "A particular analysis") }
  
  subject { @analysis }

  it { should respond_to(:code) }
  it { should respond_to(:description) }
  it { should respond_to(:title) }
  it { should respond_to(:samples) }
  
  it { should be_valid }
  
  describe "when code is not present" do
    before { @analysis.code = nil }
    it { should_not be_valid }
  end
  
  describe "when title is not present" do
    before { @analysis.title = nil }
    it { should_not be_valid }
  end
  
  describe "with blank description" do
    before { @analysis.description = " " }
    it { should_not be_valid }
  end

  describe "with a code that is too long" do
    before { @analysis.code = "a" * 12 }
    it { should_not be_valid }
  end  
  
  describe "when code is already taken" do
    before do
      analysis_with_same_code = @analysis.dup
      analysis_with_same_code.save
    end

    it { should_not be_valid }
  end
  
  describe "associated samples" do
    let(:custodian) { FactoryGirl.create(:user) }
    let(:loc) { FactoryGirl.create(:storage_location, code:'LOC1') }
    let(:sample1) { FactoryGirl.create(:sample, owner: custodian, storage_location: loc) }
    let(:sample2) { FactoryGirl.create(:sample, owner: custodian, storage_location: loc) }
    
    before do 
      @analysis.samples << sample1
      @analysis.samples << sample2
      @analysis.save
    end
    
    it "should have the right number of samples" do
      expect(@analysis.samples.count).to eql 2
    end
    
    it "associated sample should have the right number of analyses" do
      expect(sample1.analyses.count).to eql 1
      expect(sample2.analyses.count).to eql 1
    end
  end
  
end