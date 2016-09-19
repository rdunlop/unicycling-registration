class CompetitionSetup::AgeGroupTypesController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :add_breadcrumbs
  before_action :load_age_group_type, only: [:edit, :show, :update, :destroy, :duplicate]

  respond_to :html

  def index
    @age_group_types = AgeGroupType.all
    @age_group_type = AgeGroupType.new
    @age_group_type.age_group_entries.build # initial one
  end

  def create
    @age_group_type = AgeGroupType.new(age_group_type_params)
    if @age_group_type.save
      flash[:notice] = 'Age Group Type was successfully created.'
    else
      @age_group_types = AgeGroupType.all
    end

    respond_with(@age_group_type, location: age_group_types_path, action: "index")
  end

  # POST /age_group_types/:id/duplicate
  def duplicate
    duplicator = AgeGroupTypeDuplicator.new(@age_group_type)

    if duplicator.duplicate
      flash[:notice] = "Duplicated Age Group Type"
    else
      flash[:alert] = "Error duplicating age group type"
    end

    redirect_to age_group_types_path
  end

  def show
    respond_with(@age_group_type)
  end

  def destroy
    @age_group_type.destroy
    respond_with(@age_group_type)
  end

  def edit
  end

  def update
    if @age_group_type.update_attributes(age_group_type_params)
      flash[:notice] = 'Age Group Type was successfully updated.'
    end
    respond_with(@age_group_type, location: age_group_types_path)
  end

  private

  def load_age_group_type
    @age_group_type = AgeGroupType.find(params[:id])
  end

  def authorize_admin
    authorize @config, :setup_competition?
  end

  def add_breadcrumbs
    add_breadcrumb "Age Group Types", age_group_types_path
  end

  def age_group_type_params
    params.require(:age_group_type).permit(:name, :description,
                                           age_group_entries_attributes: [:id, :_destroy, :end_age, :gender, :short_description, :start_age, :wheel_size_id])
  end
end
