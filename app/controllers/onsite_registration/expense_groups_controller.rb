class OnsiteRegistration::ExpenseGroupsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @expense_groups = ExpenseGroup.admin_visible
  end

  def toggle_visibility
    @expense_group.update_attribute(:visible, !@expense_group.visible)
    redirect_to action: :index
  end

end
