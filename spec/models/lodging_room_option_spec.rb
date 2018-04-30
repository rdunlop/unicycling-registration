# == Schema Information
#
# Table name: lodging_room_options
#
#  id                   :bigint(8)        not null, primary key
#  lodging_room_type_id :integer          not null
#  position             :integer
#  name                 :string           not null
#  price_cents          :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_lodging_room_options_on_lodging_room_type_id  (lodging_room_type_id)
#

require 'spec_helper'

describe LodgingRoomOption do
  let(:lodging_room_option) { FactoryBot.create(:lodging_room_option) }
  let(:lodging_room_type) { lodging_room_option.lodging_room_type }
  let(:lodging_package) { FactoryBot.create(:lodging_package, lodging_room_type: lodging_room_type, lodging_room_option: lodging_room_option) }
  let!(:lodging_package_day) { FactoryBot.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day) }
  let(:lodging_day) { FactoryBot.create(:lodging_day, lodging_room_option: lodging_room_option) }
  let(:rei) { FactoryBot.build(:registrant_expense_item, line_item: lodging_package) }

  it "can create from factory" do
    expect(lodging_room_option.valid?).to eq(true)
  end

  describe "when an associated payment has been created" do
    before(:each) do
      @payment = FactoryBot.create(:payment_detail, line_item: lodging_package)
      lodging_room_option.reload
    end

    it "should not be able to destroy this item" do
      expect(LodgingPackage.all.count).to eq(1)
      expect(LodgingRoomOption.all.count).to eq(1)
      expect { lodging_room_option.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      expect(LodgingPackage.all.count).to eq(1)
      expect(LodgingRoomOption.all.count).to eq(1)
    end

    it "does not count this entry as a selected_item when the payment is incomplete" do
      expect(@payment.payment.completed).to eq(false)
      expect(lodging_room_option.num_selected_items(lodging_day)).to eq(0)
      expect(lodging_room_option.num_paid(lodging_day)).to eq(0)
      expect(lodging_room_option.total_amount_paid(lodging_day)).to eq(0.to_money)
    end

    it "counts this entry as a selected_item when the payment is complete" do
      pay = @payment.payment
      pay.completed = true
      pay.save!
      expect(lodging_room_option.num_selected_items(lodging_day)).to eq(1)
      expect(lodging_room_option.num_paid(lodging_day)).to eq(1)
      expect(lodging_room_option.total_amount_paid(lodging_day)).to eq(9.99.to_money)
    end
  end

  describe "with associated registrant_expense_items" do
    before(:each) do
      rei.save! # create the REI
    end

    it "should count the entry as a selected_item" do
      expect(lodging_room_option.num_selected_items(lodging_day)).to eq(1)
      expect(lodging_room_option.num_unpaid(lodging_day)).to eq(1)
    end

    describe "when the registrant is deleted" do
      before(:each) do
        reg = rei.registrant
        reg.deleted = true
        reg.save!
      end

      it "should not count the expense_item as num_unpaid" do
        expect(lodging_room_option.num_unpaid(lodging_day)).to eq(0)
      end
    end

    describe "when the registrant is not completed filling out their registration form" do
      before(:each) do
        reg = rei.registrant
        reg.status = "events"
        reg.save!
      end

      it "should not count the expense_item as num_unpaid" do
        expect(lodging_room_option.num_unpaid(lodging_day)).to eq(0)
      end

      it "should count the expense_item as num_unpaid when option is selected" do
        expect(lodging_room_option.num_unpaid(lodging_day, include_incomplete_registrants: true)).to eq(1)
      end
    end

    context "With another room option for the same room type" do
      let!(:lodging_room_option2) { FactoryBot.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
      let(:lodging_day2) { FactoryBot.create(:lodging_day, lodging_room_option: lodging_room_option2, date_offered: lodging_day.date_offered) }

      it "sums up the selected days properly" do
        expect(lodging_room_type.num_selected_items(lodging_day)).to eq(1)
        expect(lodging_room_type.num_selected_items(lodging_day2)).to eq(1)
      end
    end
  end
end
