require 'spec_helper'

describe Exporters::PaymentDetailsExporter do
  let!(:expense_item) { FactoryBot.create(:expense_item) }
  let(:exporter) { described_class.new(expense_item) }

  context "with a paid payment_detail" do
    let(:payment) { FactoryBot.create(:payment, :completed) }
    let!(:pd) { FactoryBot.create(:payment_detail, line_item: expense_item, payment: payment) }

    it "returns some data" do
      data = exporter.rows
      expect(data.count).to eq(1)
    end
  end

  context "with a free item" do
    let!(:rei) { FactoryBot.create(:registrant_expense_item, line_item: expense_item, registrant: registrant, free: true) }

    context "with a paid registration" do
      let!(:registrant) { FactoryBot.create(:spectator) } # spectators are reg_paid

      it "does return the item" do
        data = exporter.rows
        expect(data.count).to eq(1)
      end
    end

    context "with an unpaid registration" do
      let!(:registrant) { FactoryBot.create(:competitor) } # spectators are reg_paid

      it "does not return the item" do
        data = exporter.rows
        expect(data.count).to eq(0)
      end
    end
  end
end
