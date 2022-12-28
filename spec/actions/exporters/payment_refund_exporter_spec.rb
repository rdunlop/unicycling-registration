require 'spec_helper'

describe Exporters::PaymentRefundExporter do
  let(:exporter) { described_class.new }

  context "with a paid payment_detail" do
    let(:payment) { FactoryBot.create(:payment, :completed) }
    let!(:pd) { FactoryBot.create(:payment_detail, payment: payment) }

    it "returns some data" do
      data = exporter.rows
      expect(data.count).to eq(1)
    end
  end

  context "with an incomplete payment" do
    let(:payment) { FactoryBot.create(:payment) }
    let!(:pd) { FactoryBot.create(:payment_detail, payment: payment) }

    it "lists the registrant with no data" do
      data = exporter.rows
      expect(data.count).to eq(1)
      expect(data[0][2]).to be_nil
      expect(data[0][5]).to be_nil
    end
  end

  context "with a registrant without any payments" do
    let!(:registrant) { FactoryBot.create(:registrant) }

    it "lists the registrant without any other details" do
      data = exporter.rows
      expect(data.count).to eq(1)
      expect(data[0][2]).to be_nil
      expect(data[0][5]).to be_nil
    end
  end

  context "with a refunded item" do
    let(:now) { DateTime.current }
    let!(:payment) { FactoryBot.create(:payment, :completed) }
    let(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment) }
    let!(:refund) { FactoryBot.create(:refund, refund_date: now) }
    let!(:refund_detail) { FactoryBot.create(:refund_detail, payment_detail: payment_detail, refund: refund) }

    it "shows the refunded amount" do
      data = exporter.rows
      expect(data.count).to eq(1)
      expect(data[0][5]).to eq(9.99.to_money)
      expect(data[0][6]).to eq(now.iso8601)
    end
  end
end
