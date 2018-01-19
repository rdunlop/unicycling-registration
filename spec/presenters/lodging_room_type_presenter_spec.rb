require 'spec_helper'

describe LodgingRoomTypePresenter do
  let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type, maximum_available: 3) }
  let(:presenter) { described_class.new(lodging_room_type) }

  describe "#min_days_remaining" do
    # HERE ----------------
    context "with some lodging options with the same days" do
      let(:date) { Date.yesterday }
      let!(:lodging_room_option) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
      let!(:lodging_room_option2) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
      let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: date) }
      let!(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option2, date_offered: date) }

      it "shows all free" do
        expect(presenter.min_days_remaining).to eq(3)
      end
    end
  end
end
