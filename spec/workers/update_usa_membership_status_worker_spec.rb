require 'spec_helper'

describe UpdateUsaMembershipStatusWorker do
  subject(:worker) { described_class.new }

  let!(:config) { FactoryBot.create(:event_configuration, :with_usa) }
  let(:registrant) { FactoryBot.create(:competitor) }

  before do
    allow_any_instance_of(UsaMembershipChecker).to receive(:current_member?).and_return(true)
  end

  it "can check a member" do
    worker.perform(registrant.id)
    expect(registrant.reload).to be_organization_membership_confirmed
  end
end
