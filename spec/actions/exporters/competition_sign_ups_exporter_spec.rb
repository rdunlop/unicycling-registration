require 'spec_helper'

describe Exporters::CompetitionSignUpsExporter do
  before do
    @comp = FactoryBot.create(:competition)
  end

  let(:base_headers) { ["Registrant Type", "Age", "Gender", "Club", "Country"] }
  let(:exporter) { described_class.new }

  it "sets the headers" do
    headers = exporter.headers
    expect(headers).to eq(base_headers << "#{@comp.event.category} #{@comp.event} #{@comp}")
  end

  describe "with a registrant" do
    let!(:competitor) { FactoryBot.create(:event_competitor, competition: @comp) }
    let(:reg) { competitor.members.first.registrant }

    it "sets the rows" do
      data = exporter.rows
      expect(data[0]).to eq([reg.registrant_type, reg.age, reg.gender, reg.club, reg.country, @comp.to_s])
    end
  end
end
