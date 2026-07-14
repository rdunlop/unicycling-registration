class CustomLabelTypesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_ability
  before_action :load_custom_label_type, only: %i[edit update destroy]
  before_action :add_breadcrumbs

  # GET /custom_label_types
  def index
    @custom_label_types = CustomLabelType.all
  end

  def new
    @custom_label_type = CustomLabelType.new
  end

  # GET /custom_label_types/1/edit
  def edit; end

  # POST /custom_label_types
  def create
    @custom_label_type = CustomLabelType.new(custom_label_type_params)
    @custom_label_type.created_by = current_user

    if @custom_label_type.save
      redirect_to custom_label_types_path, notice: 'Custom Label was successfully created'
    else
      render action: "new"
    end
  end

  # PUT /custom_label_types/1
  def update
    if @custom_label_type.update(custom_label_type_params)
      redirect_to custom_label_types_path, notice: 'Custom Label Type was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /custom_label_types/1
  def destroy
    @custom_label_type.destroy
    redirect_to custom_label_types_path
  end

  private

  def load_custom_label_type
    @custom_label_type = CustomLabelType.find(params[:id])
  end

  def authenticate_ability
    authorize current_user, :manage_awards?
  end

  def custom_label_type_params
    params.require(:custom_label_type).permit(
      :name, :paper_size, :paper_size_custom,
      :columns, :rows,
      :top_margin, :bottom_margin, :left_margin, :right_margin,
      :column_gutter, :row_gutter,
      :description
    )
  end

  def add_breadcrumbs
    add_breadcrumb "Print/Create Awards", user_award_labels_path(current_user)
    add_breadcrumb "Custom Label Type"
  end
end
