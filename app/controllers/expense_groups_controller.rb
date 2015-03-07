class ExpenseGroupsController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_breadcrumbs

  # GET /expense_groups
  # GET /expense_groups.json
  def index
    @expense_groups = ExpenseGroup.user_manageable
    @expense_group = ExpenseGroup.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_groups }
    end
  end

  # GET /expense_groups/1/edit
  def edit
    add_breadcrumb @expense_group
  end

  # POST /expense_groups
  # POST /expense_groups.json
  def create
    respond_to do |format|
      if @expense_group.save
        format.html { redirect_to expense_groups_path, notice: 'Expense group was successfully created.' }
      else
        format.html { render action: "index" }
      end
    end
  end

  # PUT /expense_groups/1
  # PUT /expense_groups/1.json
  def update
    respond_to do |format|
      if @expense_group.update_attributes(expense_group_params)
        format.html { redirect_to expense_groups_path, notice: 'Expense group was successfully updated.' }
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

  def set_breadcrumbs
    add_breadcrumb "Other Items For Sale", expense_groups_path
  end

  def expense_group_params
    params.require(:expense_group).permit(:group_name, :position, :visible, :info_url,
                                          :competitor_free_options, :noncompetitor_free_options,
                                          :competitor_required, :noncompetitor_required, :translations_attributes => [:id, :locale, :group_name])
  end
end
