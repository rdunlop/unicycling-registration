require 'spec_helper'

describe RegistrantPresenter do
  let(:registrant) { FactoryGirl.create(:competitor) }
  let(:presenter) { described_class.new(registrant) }
  let!(:config) { FactoryGirl.create(:event_configuration, start_date: Date.today) }

  describe "#unpaid_warnings" do
    let(:warnings) { presenter.unpaid_warnings(config) }

    context "with no warnings" do
      it "has no warnings" do
        expect(warnings).to eq([])
      end
    end

    context "when under age" do
      let(:registrant) { FactoryGirl.create(:competitor, :minor, birthday: 8.years.ago, age: 8) }

      it "has warning about age" do
        expect(warnings).to eq(["Age <= 10 (wheel size)"])
      end
    end

    context "with unpaid expense" do
      let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, registrant: registrant) }

      it "has warning about payment" do
        registrant.reload
        expect(warnings).to eq(["UNPAID?"])
      end
    end

    context "with unpaid pending payment" do
      let!(:payment) { FactoryGirl.create(:payment, offline_pending: true, offline_pending_date: 1.day.ago) }
      let!(:payment_detail) { FactoryGirl.create(:payment_detail, payment: payment, registrant: registrant) }

      it "has warning about payment" do
        registrant.reload
        expect(warnings).to eq(["UNPAID?"])
      end
    end
  end
end
