require 'spec_helper'

describe Exporters::CompetitionSignUpsExporter do
  before do
    @comp = FactoryBot.create(:competition)
  end

  let(:base_headers) { ["Registrant Type", "Age", "Gender", "Club", "Country"] }
  let(:exporter) { described_class.new }

  it "sets the headers" do
    headers = exporter.headers
    expect(headers).to eq(base_headers << @comp.to_s)
  end

  describe "with a registrant" do
    let!(:competitor) { FactoryBot.create(:event_competitor, competition: @comp) }
    let(:reg) { competitor.members.first.registrant }

    it "sets the rows" do
      data = exporter.rows
      expect(data[0]).to eq([reg.registrant_type, reg.age, reg.gender, reg.club, reg.country, @comp.to_s])
    end

    xdescribe "with a registration choice for the event" do
      before do
        @ecat = @ev.event_categories.first
        @rc = FactoryBot.create(:registrant_event_sign_up, registrant: reg, event_category: @ecat, event: @ev, signed_up: true)
      end

      it "has a value in the event-signed-up target column" do
        data = exporter.rows
        expect(data[0][base_headers.count]).to eq(true)
      end
    end
  end
end
