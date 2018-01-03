require 'spec_helper'

describe LodgingRoomType do
  let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }
  let(:lodging_room_type) { lodging_room_option.lodging_room_type }
  let(:lodging_package) { FactoryGirl.create(:lodging_package, lodging_room_type: lodging_room_type, lodging_room_option: lodging_room_option) }
  let!(:lodging_package_day) { FactoryGirl.create(:lodging_package_day, lodging_package: lodging_package, lodging_day: lodging_day) }
  let(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }
  let(:rei) { FactoryGirl.build(:registrant_expense_item, line_item: lodging_package) }

  it "lodging_room_type has not reached the maximum" do
    expect(lodging_room_type.maximum_reached?(lodging_day)).to be_falsey
  end

  context "When there is a 0-limit set for the maximum available" do
    before { lodging_room_type.maximum_available = 0 }

    it "has not reached the maximum" do
      expect(lodging_room_type.maximum_reached?(lodging_day)).to be_falsey
    end
  end

  describe "when an associated payment has been created" do
    before(:each) do
      @payment = FactoryGirl.create(:payment_detail, line_item: lodging_package)
      lodging_room_type.reload
    end

    it "does not count this entry as a selected_item when the payment is incomplete" do
      expect(@payment.payment.completed).to eq(false)
      expect(lodging_room_type.num_selected_items(lodging_day)).to eq(0)
    end
  end
end

# == Schema Information
#
# Table name: lodging_room_types
#
#  id                :integer          not null, primary key
#  lodging_id        :integer          not null
#  position          :integer
#  name              :string           not null
#  description       :text
#  visible           :boolean          default(TRUE), not null
#  maximum_available :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_lodging_room_types_on_lodging_id  (lodging_id)
#
