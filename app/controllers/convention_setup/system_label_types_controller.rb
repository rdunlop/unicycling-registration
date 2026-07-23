class ConventionSetup::SystemLabelTypesController < ConventionSetup::BaseConventionSetupController
  before_action :load_system_label_type, only: %i[edit update destroy]

  def index
    authorize SystemLabelType.new, :index?
    @system_label_types = SystemLabelType.all
  end

  def new
    @system_label_type = SystemLabelType.new
    authorize @system_label_type
  end

  def edit
    authorize @system_label_type
  end

  def create
    @system_label_type = SystemLabelType.new(system_label_type_params)
    authorize @system_label_type

    if @system_label_type.save
      redirect_to system_label_types_path, notice: 'System Label Type was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    authorize @system_label_type
    if @system_label_type.update(system_label_type_params)
      redirect_to system_label_types_path, notice: 'System Label Type was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    authorize @system_label_type
    @system_label_type.destroy
    redirect_to system_label_types_path
  end

  private

  def load_system_label_type
    @system_label_type = SystemLabelType.find(params[:id])
  end

  def system_label_type_params
    params.require(:system_label_type).permit(
      :name, :paper_size, :paper_size_custom,
      :columns, :rows,
      :top_margin, :bottom_margin, :left_margin, :right_margin,
      :column_gutter, :row_gutter,
      :description
    )
  end
end
