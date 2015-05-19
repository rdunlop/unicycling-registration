class Translations::ExpenseItemsController < Admin::TranslationsController
  before_action :authenticate_user!
  load_resource

  def index
    @expense_items = ExpenseItem.all
  end

  # GET /translations/expense_items/1/edit
  def edit
  end

  # PUT /translations/expense_items/1
  def update
    if @expense_item.update_attributes(expense_item_params)
      flash[:notice] = 'ExpenseItem was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def expense_item_params
    params.require(:expense_item).permit(:translations_attributes => [:id, :locale, :name, :details_label])
  end
end
