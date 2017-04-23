require 'spec_helper'

describe Exporters::Competition::Swiss do
  let(:exporter) { described_class.new(competition.reload, heat) }
  let(:competition) { FactoryGirl.create(:timed_competition) }
  let(:heat) { nil }
  let!(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
  before do
    @reg = competitor.registrants.first
  end

  it "sets no headers" do
    headers = exporter.headers
    expect(headers).to be_nil
  end

  describe "with a lane_assignment" do
    let!(:la) do
      FactoryGirl.create(:lane_assignment, competition: competition, competitor: competitor, heat: 1, lane: 3)
    end

    context "with the same heat" do
      let(:heat) { 1 }
      it "sets the rows" do
        data = exporter.rows
        expect(data.count).to eq(1)
        expect(data[0]).to eq([nil, nil, @reg.bib_number, 3, @reg.full_name, competitor.age_group_entry_description, @reg.gender])
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

  describe "Without a lane_assignment" do
    it "returns all rows" do
      data = exporter.rows
      expect(data.count).to eq(1)
      expect(data[0]).to eq([nil, nil, @reg.bib_number, nil, @reg.full_name, competitor.age_group_entry_description, @reg.gender])
    end
  end
end
