# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean          default(FALSE), not null
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE), not null
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer          default(0), not null
#  cost_element_id        :integer
#  cost_element_type      :string
#
# Indexes
#
#  index_expense_items_expense_group_id                          (expense_group_id)
#  index_expense_items_on_cost_element_type_and_cost_element_id  (cost_element_type,cost_element_id) UNIQUE
#

require 'spec_helper'

describe LodgingRoomOption do
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }
  let(:lodging_room_type) { lodging_room_option.lodging_room_type }
  let(:lodging_package) { FactoryGirl.create(:lodging_package, lodging_room_type: lodging_room_type, lodging_room_option: lodging_room_option) }
  let!(:lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day) }
  let(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }
  let(:rei) { FactoryGirl.build(:registrant_expense_item, line_item: lodging_package) }

  it "can create from factory" do
    expect(lodging_room_option.valid?).to eq(true)
  end

  describe "when an associated payment has been created" do
    before(:each) do
      @payment = FactoryGirl.create(:payment_detail, line_item: lodging_package)
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
      let!(:lodging_room_option2) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
      let(:lodging_day2) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option2, date_offered: lodging_day.date_offered) }

      it "sums up the selected days properly" do
        expect(lodging_room_type.num_selected_items(lodging_day)).to eq(1)
        expect(lodging_room_type.num_selected_items(lodging_day2)).to eq(1)
      end
    end
  end
end
