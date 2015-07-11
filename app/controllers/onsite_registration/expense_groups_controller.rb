class OnsiteRegistration::ExpenseGroupsController < ApplicationController

  def index
    authorize @config, :setup_convention
    @expense_groups = ExpenseGroup.admin_visible
  end

  def toggle_visibility
    authorize @config, :setup_convention
    @expense_group = ExpenseGroup.find(params[:id])
    @expense_group.update_attribute(:visible, !@expense_group.visible)
    redirect_to action: :index
  end
end
