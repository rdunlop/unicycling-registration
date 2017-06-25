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
        modified_hash = reg_hash.merge(birthday: "21/05/88")
        expect(importer.find_existing_registrant(modified_hash)).to be_new_record
      end
    end
  end

  describe "#parse_birthday" do
    it "handles 98 and 2000 birthdays", :aggregate_failures do
      expect(importer.parse_birthday("10/28/91", day_first: false)).to eq(Date.new(1991, 10, 28))
      expect(importer.parse_birthday("4/08/00", day_first: false)).to eq(Date.new(2000, 4, 8))
      expect(importer.parse_birthday("12/06/01", day_first: false)).to eq(Date.new(2001, 12, 6))
      expect(importer.parse_birthday("4/14/07", day_first: false)).to eq(Date.new(2007, 4, 14))
    end
  end

  describe "#set_event_sign_up" do
    let!(:registrant) { FactoryGirl.create(:competitor) }
    let(:event_hash) do
      {
        name: "100m",
        category: "All",
        signed_up: true,
        best_time: "20.03",
        choices: {
          "Team Name" => "Awesome Team"
        }
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

      context "when resu already exists" do
        let!(:registrant_event_sign_up) { FactoryGirl.create(:registrant_event_sign_up, registrant: registrant, event: event, event_category: event.event_categories.first, signed_up: false) }

        it "does not create a new sign up" do
          expect do
            importer.set_event_sign_up(registrant, event_hash)
          end.not_to change(RegistrantEventSignUp, :count)
        end

        it "signs up, if necessary" do
          importer.set_event_sign_up(registrant, event_hash)
          expect(registrant_event_sign_up.reload.signed_up).to be_truthy
        end
      end

      context "with event choices" do
        let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, label: "Team Name") }

        it "creates the registrant choice" do
          expect do
            importer.set_event_choice(registrant, event_hash)
          end.to change(RegistrantChoice, :count).by(1)
          expect(RegistrantChoice.last.value).to eq("Awesome Team")
        end

        context "when there is already a registrant choice" do
          let!(:registrant_choice) { FactoryGirl.create(:registrant_choice, value: "Other Team", registrant: registrant, event_choice: event_choice) }

          it "updates the registrant choice" do
            expect do
              importer.set_event_choice(registrant, event_hash)
            end.not_to change(RegistrantChoice, :count)

            expect(registrant_choice.reload.value).to eq("Awesome Team")
          end
        end
      end
    end
    describe "with best time" do
      let!(:event) { FactoryGirl.create(:event, name: "100m", best_time_format: "h:mm") }

      it "creates a best time" do
        expect do
          importer.set_event_best_time(registrant, event_hash.merge(best_time: "1:20"))
        end.to change(RegistrantBestTime, :count).by(1)

        expect(RegistrantBestTime.last.event).to eq(event)
        expect(RegistrantBestTime.last.registrant).to eq(registrant)
        expect(RegistrantBestTime.last.value).to eq((60 + 20) * 60 * 100)
      end
    end
  end

  describe "when importing a single row" do
    before do
      FactoryGirl.create(:wheel_size_20)
      FactoryGirl.create(:wheel_size_24)
    end

    let!(:event) { FactoryGirl.create(:event, name: "100m", best_time_format: "(m)m:ss.xx") }
    let!(:event_choice) { FactoryGirl.create(:event_choice, event: event, label: "Team Name") }

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
            category: "All",
            signed_up: true,
            best_time: "0:20.03",
            choices: {
              "Team Name" => "100m"
            }
          }
        ]
      }
    end

    it "creates a registrant" do
      expect do
        importer.build_and_save_imported_result(reg_hash, admin_user)
      end.to change(Registrant, :count).by(1)
      expect(RegistrantChoice.count).to eq(1)
      expect(RegistrantBestTime.count).to eq(1)
    end
  end
end
