require 'spec_helper'

describe LodgingForm do
  let(:competitor) { FactoryGirl.create(:competitor) }
  let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type) }
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
  let(:form) { described_class.new(params) }

  context "#save" do
    context "with a lodging type with multiple days" do
      let!(:lodging_day1) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }
      let!(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }
      let!(:lodging_day3) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }

      describe "when selecting the whole range" do
        let(:params) do
          {
            registrant_id: competitor.id,
            lodging_room_option_id: lodging_room_option.id,
            first_day: lodging_day1.date_offered.strftime("%Y/%m/%d"),
            last_day: lodging_day3.date_offered.strftime("%Y/%m/%d")
          }
        end
        it "creates registrant_expense_items" do
          expect do
            form.save
          end.to change(RegistrantExpenseItem, :count).by(3)
        end
      end

      describe "when selecting a single day" do
        let(:params) do
          {
            registrant_id: competitor.id,
            lodging_room_option_id: lodging_room_option.id,
            first_day: lodging_day1.date_offered.strftime("%Y/%m/%d"),
            last_day: lodging_day1.date_offered.strftime("%Y/%m/%d")
          }
        end
        it "creates only a single registrant_expense_item" do
          expect do
            form.save
          end.to change(RegistrantExpenseItem, :count).by(1)
        end
      end

      describe "When selecting outside of the range" do
        let(:target_date) { (lodging_day1.date_offered - 1.day).strftime("%Y/%m/%d") }
        let(:params) do
          {
            registrant_id: competitor.id,
            lodging_room_option_id: lodging_room_option.id,
            first_day: target_date,
            last_day: lodging_day1.date_offered.strftime("%Y/%m/%d")
          }
        end

        it "returns an error that it cannot be fulfilled" do
          expect(form.save).to be_falsy
          expect(form.errors.full_messages).to eq(["#{target_date} Unable to be booked. Out of range?"])
        end
      end

      describe "When selecting only outside of the range" do
        let(:target_date) { (lodging_day1.date_offered - 5.days).strftime("%Y/%m/%d") }
        let(:target_date_end) { (lodging_day1.date_offered - 3.days).strftime("%Y/%m/%d") }
        let(:params) do
          {
            registrant_id: competitor.id,
            lodging_room_option_id: lodging_room_option.id,
            first_day: target_date,
            last_day: target_date_end
          }
        end

        it "returns an error that it cannot be fulfilled" do
          expect(form.save).to be_falsy
          expect(form.errors.full_messages).to eq(
            [
              "#{target_date} Unable to be booked. Out of range?",
              "#{target_date_end} Unable to be booked. Out of range?"
            ]
          )
        end
      end
    end

    context "when the form is not fully filled out" do
      let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 12, 14)) }

      let(:base_params) do
        {
          registrant_id: competitor.id,
          lodging_room_option_id: lodging_room_option.id,
          first_day: lodging_day.date_offered.strftime("%Y/%m/%d"),
          last_day: lodging_day.date_offered.strftime("%Y/%m/%d")
        }
      end

      context "without a lodging_room_type" do
        let(:params) { base_params.merge(lodging_room_option_id: "") }

        it "returns an error message" do
          expect(form.save).to be_falsy
          expect(form.errors.full_messages).to eq(
            [
              "Lodging room option can't be blank",
              "2017/12/14 Unable to be booked. Out of range?",
              "2017/12/14 Unable to be booked. Out of range?"
            ]
          )
        end
      end

      context "without a start date" do
        let(:params) { base_params.merge(first_day: "") }

        it "returns an error message" do
          expect(form.save).to be_falsy
          expect(form.errors.full_messages).to eq(["First day can't be blank"])
        end
      end

      context "without a end date" do
        let(:params) { base_params.merge(last_day: "") }

        it "returns an error message" do
          expect(form.save).to be_falsy
          expect(form.errors.full_messages).to eq(["Last day can't be blank"])
        end
      end
    end

    #   context "with a lodging type with a single day, with a maximum" do
    #     before do
    #       lodging_room_type.update!(maximum_available: 1)
    #     end
    #     let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 12, 17)) }

    #     let(:params) do
    #       {
    #         registrant_id: competitor.id,
    #         lodging_room_option_id: lodging_room_option.id,
    #         first_day: lodging_day.date_offered.strftime("%Y/%m/%d"),
    #         last_day: lodging_day.date_offered.strftime("%Y/%m/%d")
    #       }
    #     end
    #     context "when that day is fully bought" do
    #       let(:existing_package) { FactoryGirl.create(:lodging_package) }
    #       let!(:existing_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day)}
    #       let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, line_item: lodging_package) }

    #       it "returns falsey" do
    #         expect(form.save).to be_falsy
    #       end

    #       it "has an error message" do
    #         form.save
    #         expect(form.errors.full_messages).to eq(["2017-12-17 Unable to be booked"])
    #       end

    #       it "does not allow buying another day" do
    #         expect do
    #           form.save
    #         end.to change(RegistrantExpenseItem, :count).by(0)
    #       end
    #     end

    #     context "when the day has remaining space" do
    #       it "allows adding the new day" do
    #         expect do
    #           form.save
    #         end.to change(RegistrantExpenseItem, :count).by(1)
    #       end
    #     end
    #   end
    # end

    # describe "#selected_for" do
    #   context "with no selected elements" do
    #     it "returns a blank array" do
    #       expect(described_class.selected_for(competitor)).to eq([])
    #     end
    #   end

    #   context "with a single selected element" do
    #     let!(:lodging_day1) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 12, 28)) }
    #     let(:expense_item) { lodging_day1.expense_item }
    #     let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, registrant: competitor, expense_item: expense_item)}

    #     it "returns a single element array" do
    #       competitor.reload
    #       forms = described_class.selected_for(competitor)

    #       expect(forms.count).to eq(1)
    #       expect(forms.first.lodging_room_type_id).to eq(lodging_room_type.id)
    #       expect(forms.first.first_day).to eq("2017/12/28")
    #       expect(forms.first.last_day).to eq("2017/12/28")
    #     end
    #   end
  end
end
