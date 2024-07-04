require 'spec_helper'

describe EmailFilters::PaidLodging do
  describe "with a registrant who has paid for a lodging" do
    let(:competitor) { FactoryBot.create(:competitor) }
    let(:lodging_room_type) { FactoryBot.create(:lodging_room_type) }
    let(:lodging_room_option) { FactoryBot.create(:lodging_room_option, lodging_room_type: lodging_room_type) }
    let!(:lodging_day) { FactoryBot.create(:lodging_day, lodging_room_option: lodging_room_option, date_offered: Date.new(2017, 12, 28)) }
    let(:package) { FactoryBot.create(:lodging_package, lodging_room_option: lodging_room_option, lodging_room_type: lodging_room_option.lodging_room_type) }
    let!(:package_day) { FactoryBot.create(:lodging_package_day, lodging_package: package, lodging_day: lodging_day) }
    let!(:payment_detail) { FactoryBot.create(:payment_detail, payment: payment, registrant: competitor, line_item: package) }
    let(:payment) { FactoryBot.create(:payment, :completed) }

    it "can create a list via the lodging_room_option id" do
      @filter = described_class.new([lodging_room_option.id])
      expect(@filter.filtered_user_emails).to match_array([competitor.user.email])
    end
  end
end
