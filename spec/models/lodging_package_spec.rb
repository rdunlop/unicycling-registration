require 'spec_helper'

describe LodgingPackage do
  let(:date_offered) { Date.new(2018, 1, 5) }
  let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type, maximum_available: maximum_available) }
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
  let(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: date_offered) }
  let(:lodging_package) { FactoryGirl.create(:lodging_package, lodging_room_option: lodging_room_option, lodging_room_type: lodging_room_type) }
  let!(:lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day) }

  context "when limited number days are available" do
    let(:maximum_available) { 1 }
    let(:rei) { FactoryGirl.build(:registrant_expense_item, line_item: lodging_package) }
    context "and none are booked" do
      it "allows creating the rei" do
        expect(lodging_package.can_create_registrant_expense_item?(rei)).to eq([])
      end
    end

    context "and all are booked" do
      let(:existing_lodging_package) { FactoryGirl.create(:lodging_package, lodging_room_option: lodging_room_option, lodging_room_type: lodging_room_type) }
      let!(:existing_lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: existing_lodging_package, lodging_day: lodging_day) }
      let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, line_item: existing_lodging_package) }

      it "does not allow creating the Rei" do
        expect(lodging_package.can_create_registrant_expense_item?(rei)).to eq(["2018-01-05 Unable to be booked. None Left"])
      end
    end
  end
end
