require "spec_helper"

RSpec.describe ShowAllRegistrantsPdfJob do
  let(:report) { FactoryGirl.create(:report) }

  describe "#perform" do
    let(:order) { nil }
    let(:offset) { nil }
    let(:max) { nil }
    let(:current_user) { FactoryGirl.create(:user) }

    subject(:job) { described_class.new(report.id, order, offset, max, current_user) }

    context "Without any registrants" do
      it "does nothing" do
        job.perform_now
      end
    end
  end
end
