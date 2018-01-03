class ConventionSetup::LodgingRoomTypesController < ConventionSetup::BaseConventionSetupController
  before_action :load_lodging_room_type, except: %i[new]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/lodging_types/:id/edit
  def edit
    add_breadcrumb "Edit Lodging Type"
  end

  # PUT /convention_setup/lodging_types/1
  def update
    respond_to do |format|
      if @lodging_room_type.update_attributes(lodging_room_type_params)
        format.html { redirect_to convention_setup_lodging_room_type_path(@lodging_room_type), notice: 'Lodging Room Type was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  private

  def load_lodging_room_type
    @lodging_room_type = LodgingRoomType.find(params[:id])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Setup Lodging", convention_setup_lodgings_path
    add_breadcrumb @lodging_room_type.lodging.to_s, convention_setup_lodging_path(@lodging_room_type.lodging) if @lodging_room_type&.lodging
    add_breadcrumb "#{@lodging} Room Types", convention_setup_lodging_path(@lodging_room_type.lodging) if @lodging_room_type&.lodging
  end

  def lodging_room_type_params
    params.require(:lodging_room_type).permit(:name, :description, :maximum_available, :visible,
                                              lodging_room_options_attributes: %i[id _destroy name price])
  end
end
