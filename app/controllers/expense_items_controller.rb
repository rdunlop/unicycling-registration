class ExpenseItemsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
    @expense_item = ExpenseItem.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_items }
    end
  end

  # GET /expense_items/1
  # GET /expense_items/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense_item }
    end
  end

  # GET /expense_items/1/edit
  def edit
  end

  # POST /expense_items
  # POST /expense_items.json
  def create
    respond_to do |format|
      if @expense_item.save
        format.html { redirect_to expense_items_path, notice: 'Expense item was successfully created.' }
        format.json { render json: @expense_item, status: :created, location: expense_items_path }
      else
        @expense_items = ExpenseItem.all
        format.html { render action: "index" }
        format.json { render json: @expense_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expense_items/1
  # PUT /expense_items/1.json
  def update
    respond_to do |format|
      if @expense_item.update_attributes(expense_item_params)
        format.html { redirect_to expense_items_path, notice: 'Expense item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @expense_item.errors, status: :unprocessable_entity }
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
      format.html { redirect_to expense_items_url }
      format.json { head :no_content }
    end
  end

  private

  def expense_item_params
    params.require(:expense_item).permit(:cost, :description, :export_name, :name, :position, :expense_group_id, :has_details, :has_custom_cost, :details_label, :maximum_available , :maximum_per_registrant, :tax_percentage,
                                         :translations_attributes => [:id, :locale, :name, :description, :details_label])
  end
end
