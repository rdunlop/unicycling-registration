class AgeGroupTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  respond_to :html

  def index
    @age_group_type = AgeGroupType.new
  end

  def create
    if @age_group_type.save
      flash[:notice] = 'Age Group Type was successfully created.'
    else
      @age_group_types = AgeGroupType.all
    end

    respond_with(@age_group_type, location: age_group_types_path)
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
  def age_group_type_params
    params.require(:age_group_type).permit(:name, :description)
  end
end
