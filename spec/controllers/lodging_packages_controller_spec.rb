# == Schema Information
#
# Table name: lodging_packages
#
#  id                     :bigint(8)        not null, primary key
#  lodging_room_type_id   :integer          not null
#  lodging_room_option_id :integer          not null
#  total_cost_cents       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_lodging_packages_on_lodging_room_option_id  (lodging_room_option_id)
#  index_lodging_packages_on_lodging_room_type_id    (lodging_room_type_id)
#

require 'spec_helper'

describe LodgingPackagesController do
  before(:each) do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end
  let(:competitor) { FactoryBot.create(:competitor) }
  let!(:lodging_day) { FactoryBot.create(:lodging_day) }

  describe "DELETE #destroy" do
    let(:lodging_package) { FactoryBot.create(:lodging_package) }

    context "with a lodging expense item" do
      let!(:registrant_expense_item) { FactoryBot.create(:registrant_expense_item, line_item: lodging_package, registrant: competitor) }

      it "removes the registrant expense item" do
        expect do
          delete :destroy, params: { registrant_id: competitor.bib_number, id: lodging_package.id }
        end.to change(RegistrantExpenseItem, :count).by(-1)
      end

      it "removes the lodging_package too" do
        expect do
          delete :destroy, params: { registrant_id: competitor.bib_number, id: lodging_package.id }
        end.to change(LodgingPackage, :count).by(-1)
      end
    end

    context "When there is a pending payment for this lodging package" do
      let!(:registrant_expense_item) { FactoryBot.create(:registrant_expense_item, line_item: lodging_package, registrant: competitor) }
      let!(:payment) { FactoryBot.create(:payment) }
      let!(:payment_detail) { FactoryBot.create(:payment_detail, registrant: competitor, line_item: lodging_package) }

      it "removes the REI, but not the LP" do
        expect do
          delete :destroy, params: { registrant_id: competitor.bib_number, id: lodging_package.id }
        end.to change(RegistrantExpenseItem, :count).by(-1)
        expect(LodgingPackage.count).to eq(1)
      end
    end
  end
end
