require 'spec_helper'

describe Project do
  
  let(:contact) { FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project, code: 'P1000') }
  before { @project = Project.new(title: "Project Title", code: "P003", description: "A description of this project") }
  
  
  subject { @project }

  it { should respond_to(:code) }
  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:sample_sets) }
  it { should respond_to(:samples) }
  
  it { should be_valid }
  
  describe "when title is not present" do
    before { @project.title = nil }
    it { should_not be_valid }
  end
  
  describe "when code is not present" do
    before { @project.code = nil }
    it { should_not be_valid }
  end
  
  describe "with blank description" do
    before { @project.description = " " }
    it { should_not be_valid }
  end

  describe "with a code that is too long" do
    before { @project.code = "a" * 12 }
    it { should_not be_valid }
  end  
  
  describe "when project code is already taken" do
    before do
      project_with_same_code = @project.dup
      project_with_same_code.save
    end

    it { should_not be_valid }
  end
  
  
  describe "sample_set associations" do
    before { @project.save }
    let!(:older_sample_set) { FactoryGirl.create(:sample_set, owner: contact, project_id: @project.id.to_s, created_at: 1.day.ago) }
    let!(:newer_sample_set) { FactoryGirl.create(:sample_set, owner: contact, project_id: @project.id.to_s, created_at: 1.hour.ago) }

    it "should have the right sample_sets in the right order" do
      expect(@project.sample_sets.to_a).to eq [newer_sample_set, older_sample_set]
    end
    
  end
  
  
  describe "sample associations" do

    before { @project.save }
    let!(:older_sample) { FactoryGirl.create(:sample, owner: contact, project_id: @project.id.to_s, created_at: 1.day.ago) }
    let!(:newer_sample) { FactoryGirl.create(:sample, owner: contact, project_id: @project.id.to_s, created_at: 1.hour.ago) }

    it "should have the right samples in the right order" do
      expect(@project.samples.to_a).to eq [newer_sample, older_sample]
    end
    
  end
  
  describe "sample_sets and sample members" do
    before { @project.save }
    let!(:sample_set) do
      FactoryGirl.create(:sample_set, owner: contact, project_id: project.id.to_s, num_samples: 10, created_at: 1.day.ago)
    end
    
    it "should belong to the same project" do
      expect(sample_set.samples.first.project_id.to_s).to eql sample_set.project_id.to_s
      expect(sample_set.samples.last.project_id.to_s).to eql sample_set.project_id.to_s
    end
    
  end
  
  
end