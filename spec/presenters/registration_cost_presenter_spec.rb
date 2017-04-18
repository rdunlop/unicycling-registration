require 'spec_helper'

describe RegistrationCostPresenter do
  let(:registration_cost) { FactoryGirl.create(:registration_cost) }
  let(:presenter) { described_class.new(registration_cost.reload) }

  describe "#describe_entries" do
    context "with no ages" do
      it "shows the cost" do
        expect(presenter.describe_entries).to eq("$100.00 USD")
      end
    end

    context "with multiple ages" do
      before do
        rce = registration_cost.registration_cost_entries.first
        rce.update(min_age: 10, max_age: 50)
      end
      let!(:rce2) { FactoryGirl.create(:registration_cost_entry, min_age: 51, max_age: 99, registration_cost: registration_cost) }

      it "shows the ages" do
        expect(presenter.describe_entries).to eq("$100.00 USD (Ages 10-50), $100.00 USD (Ages 51-99)")
      end
    end

    context "given a block" do
      let!(:rce2) { FactoryGirl.create(:registration_cost_entry, min_age: 10, max_age: 20, registration_cost: registration_cost) }
      let!(:rce3) { FactoryGirl.create(:registration_cost_entry, min_age: 21, max_age: 99, registration_cost: registration_cost) }

      it "shows the ages" do
        result = presenter.describe_entries { |el| "#{el} Next" }
        expect(result).to eq("$100.00 USD Next, $100.00 USD (Ages 10-20) Next, $100.00 USD (Ages 21-99) Next")
      end
    end
  end
end
