require 'spec_helper'

describe Exporters::Competition::FinishLynx do
  let(:exporter) { described_class.new(competition.reload, heat) }
  let(:competition) { FactoryGirl.create(:timed_competition) }
  let(:heat) { 1 }
  let!(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
  before do
    @reg = competitor.registrants.first
  end

  it "sets headers" do
    headers = exporter.headers
    expect(headers).to eq([competition.id, 1, 1, competition.to_s])
  end

  describe "with a lane_assignment" do
    let(:lane) { 3 }
    let!(:la) do
      FactoryGirl.create(:lane_assignment, competition: competition, competitor: competitor, heat: 1, lane: lane)
    end

    context "with the same heat" do
      let(:heat) { 1 }
      it "sets the rows" do
        data = exporter.rows
        expect(data.count).to eq(1)
        expect(data[0]).to eq([nil, @reg.bib_number, lane, @reg.last_name, @reg.first_name, @reg.country])
      end
    end

    context "With a different heat" do
      let(:heat) { 2 }

      it "sets 0 rows" do
        data = exporter.rows
        expect(data.count).to eq(0)
      end
    end
  end
end
