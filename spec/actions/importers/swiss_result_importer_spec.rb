require 'spec_helper'

describe Importers::SwissResultImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  context "with an import file with 1 DQ row" do
    let(:processor) do
      double(file_contents: [["row_1"]],
             valid_file?: true,
             process_row: {
               bib_number: 101,
               minutes: 0,
               seconds: 0,
               thousands: 0,
               lane: 1,
               status: "DQ",
               status_description: nil,
               raw_time: "DQ"
             })
    end

    describe "when the imported data is a DQ" do
      context "when the competitor is withdrawn" do
        let(:competitor) { FactoryGirl.create(:event_competitor, status: "withdrawn", competition: competition) }
        before do
          reg = competitor.members.first.registrant
          reg.update(bib_number: 101)
        end

        it "creates no time results" do
          expect do
            expect(importer.process(1, processor)).to be_falsey
          end.not_to change(TimeResult, :count)

          expect(importer.errors).to eq(
            "1 rows processed. 1 results were not imported because the competitors do not exist and the import file lists their results as a DQ"
          )
        end
      end

      context "when the competitor does not exist" do
        it "creates no time results" do
          expect do
            expect(importer.process(1, processor)).to be_falsey
          end.not_to change(TimeResult, :count)

          expect(importer.errors).to eq(
            "1 rows processed. 1 results were not imported because the competitors do not exist and the import file lists their results as a DQ"
          )
        end
      end

      context "when the competitor exists" do
        let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }
        before do
          reg = competitor.members.first.registrant
          reg.update(bib_number: 101)
        end

        it "creates no time results" do
          expect do
            expect(importer.process(1, processor)).to be_truthy
          end.to change(TimeResult, :count).by(1)

          expect(importer.errors).to eq("")
        end
      end
    end
  end

  describe "when importing data" do
    let(:processor) do
      double(file_contents: [["row_1"]],
             valid_file?: true,
             process_row: {
               bib_number: 101,
               minutes: 0,
               seconds: 13,
               thousands: 973,
               lane: 1,
               status: "active",
               status_description: nil,
               raw_time: "00:00:13.973"
             })
    end

    context "when importing heats" do
      it "creates heat result and time result" do
        @competitor = FactoryGirl.create(:event_competitor, competition: competition)
        @reg = @competitor.members.first.registrant
        @reg.update(bib_number: 101)

        expect do
          expect(importer.process(1, processor)).to be_truthy
        end.to change(HeatLaneResult, :count).by(1)

        expect(TimeResult.count).to eq(1)
        result = TimeResult.first
        expect(result).not_to be_disqualified

        expect(result.bib_number).to eq(101)
        expect(result.number_of_laps).to be_nil

        # 0:1:34.39
        expect(result.minutes).to eq(0)
        expect(result.seconds).to eq(13)
        expect(result.thousands).to eq(973)
      end
    end

    context "When importing without heats" do
      it "does not create Heat Lane result" do
        @competitor = FactoryGirl.create(:event_competitor, competition: competition)
        @reg = @competitor.members.first.registrant
        @reg.update(bib_number: 101)
        competition.reload
        expect do
          expect(importer.process(1, processor, heats: false)).to be_truthy
        end.not_to change(HeatLaneResult, :count)
        expect(TimeResult.count).to eq(1)
      end
    end
  end

  context "when a file is not specified" do
    let(:processor) { double(valid_file?: false, errors: ["File not found"]) }

    it "returns an error message" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        expect(importer.process(false, processor)).to be_falsey
      end.not_to change(TimeResult, :count)

      expect(importer.errors).to eq("File not found")
    end
  end
end
