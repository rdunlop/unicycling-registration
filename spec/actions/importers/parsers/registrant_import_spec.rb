require 'spec_helper'

describe Importers::Parsers::RegistrantImport do
  describe "#validate_columns" do
  end

  describe "#convert_row" do
    let(:registrant_headers) { ["ID", "First Name", "Last Name", "Birthday (dd/mm/yy)", "Sex (m/f)"] }
    let(:registrant_row) { ["1", "Robin", "Dunlop", "20/05/20", "m"] }

    context "with no events" do
      it "creates the registrant hash" do
        expect(described_class.new.convert_row(registrant_headers, registrant_row)).to include(
          id: "1",
          first_name: "Robin",
          last_name: "Dunlop",
          birthday: "20/05/20",
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
          birthday: "20/05/20",
          gender: "m",
          events: [
            {
              name: "100m",
              category: "All",
              signed_up: true,
              best_time: "20.03",
              choices: [
                { "Team Name" => "100m Team" }
              ]
            }
          ]
        )
      end
    end
  end
end
