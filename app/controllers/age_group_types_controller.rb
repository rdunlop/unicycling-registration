class AgeGroupTypesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  def index
    @age_group_type = AgeGroupType.new
    @age_group_type.age_group_entries.build #initial one
  end

  def create
    if @age_group_type.save
      flash[:notice] = 'Age Group Type was successfully created.'
    else
      @age_group_types = AgeGroupType.all
    end

    respond_with(@age_group_type, location: age_group_types_path, action: "index")
  end

  def show
    respond_with(@age_group_type)
  end

  def destroy
    @age_group_type.destroy
    respond_with(@age_group_type)
  end

  def set_sort
    add_breadcrumb "Manage Age Group Type", age_group_type_path(@age_group_type)
    add_breadcrumb "Sort Age Group Entries"
  end

  def sort
    @age_group_entries = @age_group_type.age_group_entries
    AgeGroupType.transaction do
      @age_group_entries.each do |age_group_entry|
        # Prevent doing a cascade-update for each age group entry change
        age_group_entry.update_column(:position, params['age_group_entry'].index(age_group_entry.id.to_s) + 1)
      end
      # update the parent, and cascaed
      @age_group_type.touch
    end
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
    params.require(:age_group_type).permit(:name, :description,
      :age_group_entries_attributes =>[:id, :_destroy, :end_age, :gender, :short_description, :start_age, :wheel_size_id])
  end
end
