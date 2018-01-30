require 'spec_helper'

describe LodgingRoomTypePresenter do
  let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type, maximum_available: maximum_available) }
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
  let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }

  let(:presenter) { described_class.new(lodging_room_type) }

  describe "#min_days_remaining" do
    context "with no maximum_available specified" do
      let(:maximum_available) { nil }

      it "returns empty string" do
        expect(presenter.min_days_remaining).to eq("")
      end
    end

    context "With 3 maximum_available" do
      let(:maximum_available) { 3 }

      it "returns 3 remaining" do
        expect(presenter.min_days_remaining).to eq(3)
      end

      context "with a lodging_package" do
        let(:lodging_package) { FactoryGirl.create(:lodging_package, lodging_room_type: lodging_room_type, lodging_room_option: lodging_room_option) }
        let!(:lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_day: lodging_day, lodging_package: lodging_package) }

        context "with one selected" do
          let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, line_item: lodging_package) }

          it "return 2 available" do
            expect(presenter.min_days_remaining).to eq(2)
          end
        end

        context "with one paid" do
          let(:payment) { FactoryGirl.create(:payment, :completed) }
          let!(:payment_detail) { FactoryGirl.create(:payment_detail, line_item: lodging_package, payment: payment) }

          it "returns 2 available" do
            expect(presenter.min_days_remaining).to eq(2)
          end
        end
      end
    end
  end
end
