require 'spec_helper'

describe LodgingPackagePresenter do
  let(:lodging_package) { FactoryGirl.create(:lodging_package) }
  let(:lodging_room_option) { lodging_package.lodging_room_option }
  let(:presenter) { described_class.new(lodging_package) }

  describe "#check_in_day" do
    context "with no lodging_days" do
      it "says none" do
        expect(presenter.check_in_day).to eq("none")
      end
    end

    context "with one lodging day" do
      let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 1)) }
      let!(:lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day) }

      it "says that one day" do
        expect(presenter.check_in_day).to eq("Jan 01, 2017")
      end
    end

    context "with a range of lodging days" do
      let!(:lodging_day1) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 1)) }
      let!(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 1, 2)) }
      let!(:lodging_package_day1) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day1) }
      let!(:lodging_package_day2) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day2) }

      it "says those days" do
        expect(presenter.check_in_day).to eq("Jan 01, 2017")
        expect(presenter.check_out_day).to eq("Jan 03, 2017")
      end
    end
  end
end
