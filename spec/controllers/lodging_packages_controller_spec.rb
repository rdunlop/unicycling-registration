# == Schema Information
#
# Table name: lodgings
#
#  id          :integer          not null, primary key
#  position    :integer
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
    end
  end
end
