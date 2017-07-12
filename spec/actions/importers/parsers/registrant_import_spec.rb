require 'spec_helper'

describe Importers::Parsers::RegistrantImport do
  describe "#convert_row" do
    let(:registrant_headers) { ["ID", "First Name", "Last Name", "Birthday (dd/mm/yyyy)", "Sex (m/f)"] }
    let(:registrant_row) { ["1", "Robin", "Dunlop", "20/05/1982", "m"] }

    context "with no events" do
      it "creates the registrant hash" do
        expect(described_class.new.convert_row(registrant_headers, registrant_row)).to include(
          id: "1",
          first_name: "Robin",
          last_name: "Dunlop",
          birthday: "20/05/1982",
          gender: "m"
        )
      end
    end

    context "with 1 event" do
      let!(:event) { FactoryGirl.create(:event, name: "100m", best_time_format: "(m)m:ss.xx") }
      let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, cell_type: "text", label: "Team Name") }
      let(:event_headers) { ["EV: 100m - Signed Up (Y/N)", "EV: 100m - Category (All)", "EV: 100m - Best Time ((m)m:ss.xx)", "EV: 100m - Choice: Team Name"] }
      let(:event_row) { ["Y", "All", "20.03", "100m Team"] }

      it "creates the event hash" do
        expect(described_class.new.convert_row(registrant_headers + event_headers, registrant_row + event_row)).to include(
          id: "1",
          first_name: "Robin",
          last_name: "Dunlop",
          birthday: "20/05/1982",
          gender: "m",
          events: [
            {
              name: "100m",
              category: "All",
              signed_up: true,
              best_time: "20.03",
              choices: {
                "Team Name" => "100m Team"
              }
            }
          ]
        )
      end
    end
  end

  describe "#extract_file" do
    let!(:event) { FactoryGirl.create(:event, name: "100m", best_time_format: "(m)m:ss.xx") }
    let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, cell_type: "text", label: "Team Name") }

    let(:test_file) { fixture_path + '/registrants.csv' }
    let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
    let(:importer) { described_class.new(sample_input) }

    it "read the registrant file" do
      input_data = importer.extract_file
      expect(input_data.count).to eq(2)
      expect(input_data[0]).to eq(["1", "Robin", "Dunlop", "20/05/1982", "m", "Y", "All", "20.03", "100m Team"])
      expect(input_data[1]).to eq(["2", "Scott", "Wilton", "28/02/1995", "m", "Y", "All", "12.33", "Best Team"])
    end

    it "has valid headers" do
      expect(importer).to be_valid_file
    end

    it "converts the row entries" do
      importer.extract_file
      input_data = importer.process_row(["1", "Robin", "Dunlop", "20/05/1982", "m", "Y", "All", "20.03", "100m Team"])
      expect(input_data).to eq(
        id: "1",
        first_name: "Robin",
        last_name: "Dunlop",
        birthday: "20/05/1982",
        gender: "m",
        events: [
          {
            name: "100m",
            category: "All",
            signed_up: true,
            best_time: "20.03",
            choices: {
              "Team Name" => "100m Team"
            }
          }
        ]
      )
      input_data = importer.process_row(["2", "Scott", "Wilton", "28/02/1995", "m", "Y", "All", "12.33", "Best Team"])
      expect(input_data).to eq(
        id: "2",
        first_name: "Scott",
        last_name: "Wilton",
        birthday: "28/02/1995",
        gender: "m",
        events: [
          {
            name: "100m",
            category: "All",
            signed_up: true,
            best_time: "12.33",
            choices: {
              "Team Name" => "Best Team"
            }
          }
        ]
      )
    end

    describe "#validate_contents" do
      it "validates the headers" do
        importer.extract_file
        importer.validate_headers
        expect(importer.errors.count).to eq(0)
      end
    end
  end
end
