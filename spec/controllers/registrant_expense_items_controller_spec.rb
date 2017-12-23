# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  line_item_id      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#  line_item_type    :string
#
# Indexes
#
#  index_registrant_expense_items_registrant_id  (registrant_id)
#  registrant_expense_items_line_item            (line_item_id,line_item_type)
#

require 'spec_helper'

describe RegistrantExpenseItemsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @reg = FactoryGirl.create(:registrant, user: @user)
    @exp = FactoryGirl.create(:expense_item)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # RegistrantGroup. As you add validations to RegistrantGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { free: false,
      details: nil,
      line_item_id: @exp.id,
      line_item_type: @exp.class.name}
  end

  describe "POST create" do
    before { request.env["HTTP_REFERER"] = registrant_build_path(Registrant.last.id, :expenses) }
    describe "with valid params" do
      it "creates a new RegistrantExpenseItem" do
        expect do
          post :create, params: { registrant_expense_item: valid_attributes, registrant_id: @reg.to_param }
        end.to change(RegistrantExpenseItem, :count).by(1)
      end

      it "redirects to the created item_registrants_path" do
        post :create, params: { registrant_expense_item: valid_attributes, registrant_id: @reg.to_param }
        expect(response).to redirect_to(registrant_build_path(Registrant.last.id, :expenses))
      end
    end

    describe "with invalid params" do
      it "does not create a new registrant_expense_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrantExpenseItem).to receive(:save).and_return(false)
        expect do
          post :create, params: { registrant_expense_item: { details: "invalid value" }, registrant_id: @reg.to_param }
        end.not_to change(RegistrantExpenseItem, :count)
      end

      it "redirects back to build path" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(RegistrantExpenseItem).to receive(:save).and_return(false)
        post :create, params: { registrant_expense_item: { "details" => "invalid value" }, registrant_id: @reg.to_param }
        expect(response).to redirect_to(registrant_build_path(Registrant.last.id, :expenses))
      end
    end
  end

  describe "DELETE destroy" do
    before { request.env["HTTP_REFERER"] = registrant_build_path(Registrant.last.id, :expenses) }

    it "destroys the requested registrant_expense_item" do
      registrant_expense_item = FactoryGirl.create(:registrant_expense_item, registrant: @reg)
      expect do
        delete :destroy, params: { id: registrant_expense_item.to_param, registrant_id: @reg.to_param }
      end.to change(RegistrantExpenseItem, :count).by(-1)
    end

    it "redirects to the registrant_items list" do
      registrant_expense_item = FactoryGirl.create(:registrant_expense_item, registrant: @reg)
      reg = registrant_expense_item.registrant
      delete :destroy, params: { id: registrant_expense_item.to_param, registrant_id: @reg.to_param }
      expect(response).to redirect_to(registrant_build_path(reg.id, :expenses))
    end
  end
end
