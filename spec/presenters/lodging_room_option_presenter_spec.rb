require 'spec_helper'

describe LodgingRoomOptionPresenter do
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }
  let(:presenter) { described_class.new(lodging_room_option) }

  describe "#days_available" do
    context "with no lodging_days" do
      it "says none" do
        expect(presenter.days_available).to eq("none")
      end
    end

    context "with one lodging day" do
      let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 1)) }

      it "says that one day" do
        expect(presenter.days_available).to eq("Jan 01, 2017 - Jan 02, 2017")
      end
    end

    context "with a range of lodging days" do
      let!(:lodging_day1) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 1)) }
      let!(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 2)) }

      it "says those days" do
        expect(presenter.days_available).to eq("Jan 01, 2017 - Jan 03, 2017")
      end
    end

    context "with a broken range of lodging days" do
      let!(:lodging_day1) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 1)) }
      let!(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 2)) }
      let!(:lodging_day3) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 5)) }
      let!(:lodging_day4) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 6)) }

      it "says those ranges of days" do
        expect(presenter.days_available).to eq("Jan 01, 2017 - Jan 03, 2017, Jan 05, 2017 - Jan 07, 2017")
      end
    end
  end
end
