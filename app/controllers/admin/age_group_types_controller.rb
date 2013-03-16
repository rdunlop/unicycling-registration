class Admin::AgeGroupTypesController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @age_group_types = AgeGroupType.all
    @age_group_type = AgeGroupType.new
  end

  def create
    @age_group_type = AgeGroupType.new(params[:age_group_type])

    respond_to do |format|
      if @age_group_type.save
        format.html { redirect_to admin_age_group_types_path, notice: 'Age Group Type was successfully created.' }
        format.json { render json: @age_group_type, status: :created, location: admin_age_group_types_path }
      else
        @age_group_types = AgeGroupType.all
        format.html { render action: "index" }
        format.json { render json: @age_group_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @age_group_type = AgeGroupType.find(params[:id])
    @age_group_type.destroy
    respond_to do |format|
      format.html { redirect_to admin_age_group_types_path }
      format.json { head :no_content }
    end
  end

  def edit
  end

  def update
    @age_group_type = AgeGroupType.find(params[:id])

    respond_to do |format|
      if @age_group_type.update_attributes(params[:age_group_type])
        format.html { redirect_to admin_age_group_types_path, notice: 'Age Group Type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @age_group_type.errors, status: :unprocessable_entity }
      end
    end
  end
end
