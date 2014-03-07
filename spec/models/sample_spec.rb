require 'spec_helper'

describe Sample do

  let(:user) { FactoryGirl.create(:user) }
  before do
    # This code is not idiomatically correct.
    @sample = Sample.new(facility_id: 1, sampled: false, owner_id: user.id)
  end

  subject { @sample }
  
  it { should respond_to( :sample_set_id   ) }
  it { should respond_to( :owner_id        ) }
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
  
  its(:owner) { should eq user }

  it { should be_valid }

  describe "when owner_id is not present" do
    before { @sample.owner_id = nil }
    it { should_not be_valid }
  end
end
