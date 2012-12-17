class ExpenseItemsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /expense_items
  # GET /expense_items.json
  def index
    @expense_items = ExpenseItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_items }
    end
  end

  # GET /expense_items/1
  # GET /expense_items/1.json
  def show
    @expense_item = ExpenseItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense_item }
    end
  end

  # GET /expense_items/new
  # GET /expense_items/new.json
  def new
    @expense_item = ExpenseItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @expense_item }
    end
  end

  # GET /expense_items/1/edit
  def edit
    @expense_item = ExpenseItem.find(params[:id])
  end

  # POST /expense_items
  # POST /expense_items.json
  def create
    @expense_item = ExpenseItem.new(params[:expense_item])

    respond_to do |format|
      if @expense_item.save
        format.html { redirect_to @expense_item, notice: 'Expense item was successfully created.' }
        format.json { render json: @expense_item, status: :created, location: @expense_item }
      else
        format.html { render action: "new" }
        format.json { render json: @expense_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expense_items/1
  # PUT /expense_items/1.json
  def update
    @expense_item = ExpenseItem.find(params[:id])

    respond_to do |format|
      if @expense_item.update_attributes(params[:expense_item])
        format.html { redirect_to @expense_item, notice: 'Expense item was successfully updated.' }
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
    @expense_item = ExpenseItem.find(params[:id])
    unless @expense_item.destroy
      flash[:alert] = @expense_item.errors.full_messages
    end

    respond_to do |format|
      format.html { redirect_to expense_items_url }
      format.json { head :no_content }
    end
  end
end
