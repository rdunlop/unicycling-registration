# == Schema Information
#
# Table name: lodging_packages
#
#  id                     :integer          not null, primary key
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
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let(:competitor) { FactoryGirl.create(:competitor) }
  let!(:lodging_day) { FactoryGirl.create(:lodging_day) }

  describe "DELETE #destroy" do
    let(:lodging_package) { FactoryGirl.create(:lodging_package) }

    context "with a lodging expense item" do
      let!(:registrant_expense_item) { FactoryGirl.create(:registrant_expense_item, line_item: lodging_package, registrant: competitor) }

      it "removes the registrant expense item" do
        expect do
          delete :destroy, params: { registrant_id: competitor.bib_number, id: lodging_package.id}
        end.to change(RegistrantExpenseItem, :count).by(-1)
      end

      it "removes the lodging_package too" do
        expect do
          delete :destroy, params: { registrant_id: competitor.bib_number, id: lodging_package.id}
        end.to change(LodgingPackage, :count).by(-1)
      end
    end
  end
end
