class ExpenseGroupsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /expense_groups
  # GET /expense_groups.json
  def index
    @expense_group = ExpenseGroup.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_groups }
    end
  end

  # GET /expense_groups/1
  # GET /expense_groups/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense_group }
    end
  end

  # GET /expense_groups/1/edit
  def edit
  end

  # POST /expense_groups
  # POST /expense_groups.json
  def create
    respond_to do |format|
      if @expense_group.save
        format.html { redirect_to @expense_group, notice: 'Expense group was successfully created.' }
        format.json { render json: @expense_group, status: :created, location: @expense_group }
      else
        format.html { render action: "index" }
        format.json { render json: @expense_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expense_groups/1
  # PUT /expense_groups/1.json
  def update
    respond_to do |format|
      if @expense_group.update_attributes(expense_group_params)
        format.html { redirect_to @expense_group, notice: 'Expense group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @expense_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_groups/1
  # DELETE /expense_groups/1.json
  def destroy
    @expense_group.destroy

    respond_to do |format|
      format.html { redirect_to expense_groups_url }
      format.json { head :no_content }
    end
  end

  private

  def expense_group_params
    params.require(:expense_group).permit(:group_name, :position, :admin_visible, :visible, :info_url,
                                          :competitor_free_options, :noncompetitor_free_options,
                                          :competitor_required, :noncompetitor_required, :translations_attributes => [:id, :locale, :group_name])
  end
end
