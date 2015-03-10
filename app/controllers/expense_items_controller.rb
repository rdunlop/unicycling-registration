class ExpenseItemsController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource :expense_group, except: :details
  load_and_authorize_resource

  before_action :set_breadcrumbs

  # GET /expense_items/1/details
  def details
    add_payment_summary_breadcrumb
    add_breadcrumb "#{@expense_item.to_s} Items"

    @paid_details = @expense_item.paid_items
    @unpaid_details = @expense_item.unpaid_items
  end

  # ############################
  # NORMAL CRUD BELOW THIS LINE
  # ############################

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
    @expense_item.expense_group = @expense_group
    @expense_item.position ||= (@expense_group.expense_items.map(&:position).max || 0 )+ 1
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
      if @expense_item.update_attributes(expense_item_params)
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

  def set_breadcrumbs
    add_breadcrumb "Other Items For Sale", expense_groups_path
    add_breadcrumb "#{@expense_group} Expense Items", expense_group_expense_items_path(@expense_group) if @expense_group
  end

  def expense_item_params
    params.require(:expense_item).permit(:cost, :name, :position, :has_details,
                                         :has_custom_cost, :details_label, :maximum_available , :maximum_per_registrant, :tax,
                                         :translations_attributes => [:id, :locale, :name, :details_label])
  end
end
