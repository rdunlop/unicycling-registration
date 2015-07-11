class OnsiteRegistration::ExpenseGroupsController < ApplicationController
  before_action :authorize_setup

  def index
    @expense_groups = ExpenseGroup.admin_visible
  end

  def toggle_visibility
    @expense_group = ExpenseGroup.find(params[:id])
    @expense_group.update_attribute(:visible, !@expense_group.visible)
    redirect_to action: :index
  end

  private

  def authorize_setup
    authorize @config, :setup_convention
  end

end
