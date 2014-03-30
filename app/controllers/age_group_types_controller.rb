class AgeGroupTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  def index
    @age_group_type = AgeGroupType.new
  end

  def create
    respond_to do |format|
      if @age_group_type.save
        format.html { redirect_to age_group_types_path, notice: 'Age Group Type was successfully created.' }
        format.json { render json: @age_group_type, status: :created, location: age_group_types_path }
      else
        @age_group_types = AgeGroupType.all
        format.html { render action: "index" }
        format.json { render json: @age_group_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @age_group_type.destroy
    respond_with(@age_group_type)
  end

  def edit
  end

  def update

    respond_to do |format|
      if @age_group_type.update_attributes(age_group_type_params)
        format.html { redirect_to age_group_types_path, notice: 'Age Group Type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @age_group_type.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def age_group_type_params
    params.require(:age_group_type).permit(:name, :description)
  end
end
