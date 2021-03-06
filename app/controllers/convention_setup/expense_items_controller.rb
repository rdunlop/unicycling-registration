class ConventionSetup::ExpenseItemsController < ConventionSetup::BaseConventionSetupController
  include SortableObject

  before_action :load_expense_group, except: :update_row_order # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :load_expense_item, except: %i[index create]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  # GET /expense_items
  # GET /expense_items.json
  def index
    @expense_items = @expense_group.expense_items.user_manageable.ordered
    @expense_item = @expense_group.expense_items.build

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_items }
    end
  end

  # GET /expense_items/1/edit
  def edit
    add_breadcrumb "Edit Expense Item"
  end

  # POST /expense_items
  # POST /expense_items.json
  def create
    @expense_item = ExpenseItem.new(expense_item_params)
    @expense_item.expense_group = @expense_group
    respond_to do |format|
      if @expense_item.save
        format.html { redirect_to expense_group_expense_items_path(@expense_group), notice: 'Expense item was successfully created.' }
      else
        @expense_items = @expense_group.expense_items.user_manageable.ordered
        format.html { render action: "index" }
      end
    end
  end

  # PUT /expense_items/1
  # PUT /expense_items/1.json
  def update
    respond_to do |format|
      if @expense_item.update(expense_item_params)
        format.html { redirect_to expense_group_expense_items_path(@expense_group), notice: 'Expense item was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /expense_items/1
  # DELETE /expense_items/1.json
  def destroy
    unless @expense_item.destroy
      flash[:alert] = @expense_item.errors.full_messages
    end

    respond_to do |format|
      format.html { redirect_to expense_group_expense_items_url(@expense_group) }
      format.json { head :no_content }
    end
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def load_expense_group
    @expense_group = ExpenseGroup.find(params[:expense_group_id])
  end

  def load_expense_item
    @expense_item = ExpenseItem.find(params[:id])
  end

  def sortable_object
    ExpenseItem.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb "Items For Sale", expense_groups_path
    add_breadcrumb "#{@expense_group} Expense Items", expense_group_expense_items_path(@expense_group) if @expense_group
  end

  def expense_item_params
    params.require(:expense_item).permit(:cost, :name, :has_details,
                                         :has_custom_cost, :details_label, :maximum_available, :maximum_per_registrant, :tax,
                                         translations_attributes: %i[id locale name details_label])
  end
end
