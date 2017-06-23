require 'spec_helper'

describe Importers::RegistrantDataImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:importer) { described_class.new(admin_user) }

  describe "#find_existing_registrant" do
    let(:reg_hash) do
      {
        first_name: "Bob",
        last_name: "Smith",
        birthday: "20/01/07"
      }
    end

    it "initializes one if none exist" do
      expect(importer.find_existing_registrant(reg_hash)).to be_new_record
    end

    context "when one already exists" do
      let!(:registrant) { FactoryGirl.create(:registrant, first_name: "Bob", last_name: "Smith", birthday: Date.new(2007, 0o1, 20)) }

      it "returns the existing registrant" do
        expect(importer.find_existing_registrant(reg_hash)).to eq(registrant)
      end

      it "returns different-case registrant name" do
        modified_hash = reg_hash.merge(first_name: "bob")
        expect(importer.find_existing_registrant(modified_hash)).to eq(registrant)
      end

      it "needs the birthday to be the same" do
        modified_hash = reg_hash.merge(birthday: "21/5/88")
        expect(importer.find_existing_registrant(modified_hash)).to be_new_record
      end
    end
  end

  describe "#parse_birthday" do
    it "handles 98 and 2000 birthdays", :aggregate_failures do
      expect(importer.parse_birthday("10/28/91", day_first: false)).to eq(Date.new(1991, 10, 28))
      expect(importer.parse_birthday("4/8/00", day_first: false)).to eq(Date.new(2000, 4, 8))
      expect(importer.parse_birthday("12/6/01", day_first: false)).to eq(Date.new(2001, 12, 6))
      expect(importer.parse_birthday("4/14/07", day_first: false)).to eq(Date.new(2007, 4, 14))
    end
  end

  describe "#set_event_sign_up" do
    let!(:registrant) { FactoryGirl.create(:competitor) }
    let(:event_hash) do
      {
        name: "100m",
        signed_up: true,
        best_time: "20.03",
        choices: [
          { "Team Name" => "100m" }
        ]
      }
    end

    context "with a single event" do
      let!(:event) { FactoryGirl.create(:event, name: "100m") }

      it "creates a registrant_event_sign_up" do
        expect do
          importer.set_event_sign_up(registrant, event_hash)
        end.to change(RegistrantEventSignUp, :count).by(1)

        resu = RegistrantEventSignUp.last
        expect(resu).to be_signed_up
        expect(resu.event_category).to eq(event.event_categories.first)
      end

      context "when already signed up" do
        it "does not create a new sign up" do
        end

        it "un-signs up, if necessary" # pending
      end

      context "with event choices" do
      end
    end

    context "with 2 events" do
    end
  end

  describe "when importing a single row" do
    let!(:event) { FactoryGirl.create(:event, name: "100m") }

    let(:reg_hash) do
      {
        id: "1",
        first_name: "Bob",
        last_name: "Smith",
        birthday: "10/4/76",
        gender: "m",
        events: [
          {
            name: "100m",
            signed_up: true,
            best_time: "20.03",
            choices: [
              { "Team Name" => "100m" }
            ]
          }
        ]
      }
    end

    it "creates a registrant" do
      expect do
        importer.build_and_save_imported_result(reg_hash, admin_user)
      end.to change(Registrant, :count).by(1)
    end
  end
end
