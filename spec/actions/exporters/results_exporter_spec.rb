require 'spec_helper'

describe Exporters::ResultsExporter do
  let!(:result) { FactoryGirl.create(:result, :overall) }
  let(:exporter) { described_class.new }

  it "returns some data" do
    data = exporter.rows
    expect(data.count).to eq(1)
  end
end
