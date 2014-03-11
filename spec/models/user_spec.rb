require 'spec_helper'

describe User do

  before { @user = User.new(firstname: "Example", surname: "Blabla", email: "user@example.com",
                            password: "foobar", password_confirmation: "foobar") }
  
  subject { @user }

  it { should respond_to(:firstname) }
  it { should respond_to(:surname) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:sample_sets) }
  it { should respond_to(:my_sample_sets) }
  it { should respond_to(:samples) }
  it { should respond_to(:facilities) }

  it { should be_valid }
  it { should_not be_admin }


  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end
  
  
  # Presence checks
  describe "when firstname is not present" do
    before { @user.firstname = " " }
    it { should_not be_valid }
  end
  
  describe "when surname is not present" do
    before { @user.surname = " " }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before do
      @user = User.new(firstname: "Example", surname: "blabla", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end
  
  
  #Length checks
  describe "when firstname is too long" do
    before { @user.firstname = "a" * 51 }
    it { should_not be_valid }
  end
 
 describe "when surname is too long" do
    before { @user.surname = "a" * 51 }
    it { should_not be_valid }
  end
  
  
  # email checks
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end 
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  
  #Password checks
  describe "when password is not present" do
    before do
      @user = User.new(firstname: "Example", surname: "bla" ,email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
 describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  
  describe "sample_set associations" do

    before { @user.save }
    let!(:older_sample_set) do
      FactoryGirl.create(:sample_set, owner: @user, created_at: 1.day.ago)
    end
    let!(:newer_sample_set) do
      FactoryGirl.create(:sample_set, owner: @user, created_at: 1.hour.ago)
    end

    it "should have the right sample_sets in the right order" do
      expect(@user.sample_sets.to_a).to eq [newer_sample_set, older_sample_set]
    end
    
    it "should destroy associated sample_sets" do
      sample_sets = @user.sample_sets.to_a
      @user.destroy
      expect(sample_sets).not_to be_empty
      sample_sets.each do |sample_set|
        expect(SampleSet.where(id: sample_set.id)).to be_empty
      end
    end
    
    describe "status" do
      let(:unowned_sample_set) do
        FactoryGirl.create(:sample_set, owner: FactoryGirl.create(:user))
      end

      its(:my_sample_sets) { should include(newer_sample_set) }
      its(:my_sample_sets) { should include(older_sample_set) }
      its(:my_sample_sets) { should_not include(unowned_sample_set) }
    end
    
  end
  
  describe "sample associations" do

    before { @user.save }
    let!(:older_sample) do
      FactoryGirl.create(:sample, owner: @user, created_at: 1.day.ago)
    end
    let!(:newer_sample) do
      FactoryGirl.create(:sample, owner: @user, created_at: 1.hour.ago)
    end

    it "should have the right samples in the right order" do
      expect(@user.samples.to_a).to eq [newer_sample, older_sample]
    end
    
    it "should destroy associated samples" do
      samples = @user.samples.to_a
      @user.destroy
      expect(samples).not_to be_empty
      samples.each do |sample|
        expect(Sample.where(id: sample.id)).to be_empty
      end
    end
  end
  
  describe "facility associations" do

    before { @user.save }
    
    let!(:upper_facility) do
      FactoryGirl.create(:facility, contact: @user, code: 'ZZZZ')
    end
    let!(:lower_facility) do
      FactoryGirl.create(:facility, contact: @user, code: 'AAAA')
    end

    it "should have the right facilities in alphabetic order" do
      expect(@user.facilities.to_a).to eq [lower_facility, upper_facility]
    end
    
    it "should deal with orphaned facilities upon contact/user deletion" do
    end
  end
  
end
