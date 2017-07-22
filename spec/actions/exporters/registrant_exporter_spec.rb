require 'spec_helper'

describe Exporters::RegistrantExporter do
  describe "#headers" do
    let(:headers) { described_class.new.headers }
    let(:expected_headers) do
      [
        "Id",
        "First Name",
        "Last Name",
        "Birthday (dd/mm/yyyy)",
        "Sex (m/f)"
      ]
    end

    it "describes the registrant headers" do
      expect(headers).to eq(expected_headers)
    end

    context "with an event" do
      let!(:event) { FactoryGirl.create(:event, best_time_format: "none", name: "100m") }
      let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, label: "Team") }

      let(:expected_headers) do
        [
          "EV: 100m - Signed Up (Y/N)",
          "EV: 100m - Category (All)",
          "EV: 100m - Best Time (none)",
          "EV: 100m - Choice: Team"
        ]
      end

      it "describes the event headers" do
        expect(headers).to include(*expected_headers)
      end

      context "with 2 categories" do
        let!(:second_category) { FactoryGirl.create(:event_category, event: event, name: "Junior") }

        it "has the 2 categories as header" do
          expect(headers).to include("EV: 100m - Category (All/Junior)")
        end
      end
    end
  end

  describe "#rows" do
    let!(:registrant) { FactoryGirl.create(:competitor, birthday: Date.new(1998, 4, 20), gender: "Male") }

    let(:rows) { described_class.new.rows }

    let(:expected_row) do
      [
        registrant.bib_number.to_s,
        registrant.first_name,
        registrant.last_name,
        "20/04/1998",
        "m"
      ]
    end

    it "includes the base information" do
      expect(rows.first).to eq(expected_row)
    end

    context "when the registrant is a spectator (no birthday)" do
      let!(:registrant) { FactoryGirl.create(:spectator, birthday: nil, gender: nil) }

      let(:expected_row) do
        [
          registrant.bib_number.to_s,
          registrant.first_name,
          registrant.last_name,
          "",
          ""
        ]
      end

      it "includes the base information" do
        expect(rows.first).to eq(expected_row)
      end
    end

    context "with an event with choices" do
      let!(:event) { FactoryGirl.create(:event, best_time_format: "none", name: "100m") }
      let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, label: "Team") }

      let!(:resu) { FactoryGirl.create(:registrant_event_sign_up, registrant: registrant, signed_up: true, event_category: event.event_categories.first) }

      context "when registrant does not have the choice" do
        let(:expected_row) do
          [
            "Y",
            "All",
            "",
            ""
          ]
        end
        it "includes the event sign up details" do
          expect(rows.first).to include(*expected_row)
        end
      end

      context "When registrant has the choice" do
        let!(:rc) { FactoryGirl.create(:registrant_choice, registrant: registrant, event_choice: event_choice, value: "My Team") }

        let(:expected_row) do
          [
            "Y",
            "All",
            "",
            "My Team"
          ]
        end
        it "includes the event sign up details" do
          expect(rows.first).to include(*expected_row)
        end
      end
    end
  end
end
