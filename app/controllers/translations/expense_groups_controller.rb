class Translations::ExpenseGroupsController < Admin::TranslationsController
  before_action :authenticate_user!
  load_resource

  def index
    @expense_groups = ExpenseGroup.all
  end

  # GET /translations/expense_groups/1/edit
  def edit
  end

  # PUT /translations/expense_groups/1
  def update
    if @expense_group.update_attributes(expense_group_params)
      flash[:notice] = 'ExpenseGroup was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def expense_group_params
    params.require(:expense_group).permit(translations_attributes: [:id, :locale, :group_name])
  end
end
