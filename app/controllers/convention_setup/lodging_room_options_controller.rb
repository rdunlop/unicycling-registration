class ConventionSetup::LodgingRoomOptionsController < ConventionSetup::BaseConventionSetupController
  before_action :load_lodging_room_option
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/lodging_room_option/:id/edit
  def edit
    add_breadcrumb "Edit Lodging Room Option"
  end

  # PUT /convention_setup/lodging_room_option/1
  def update
    respond_to do |format|
      if @lodging_room_option.update_attributes(lodging_room_option_params)
        format.html { redirect_to convention_setup_lodging_room_option_path(@lodging_room_option), notice: 'Lodging Room Option was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  private

  def load_lodging_room_option
    @lodging_room_option = LodgingRoomOption.find(params[:id])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Setup Lodging", convention_setup_lodgings_path
    add_breadcrumb "#{@lodging} Room Types", convention_setup_lodging_path(@lodging_room_option.lodging_room_type.lodging) if @lodging_room_option&.lodging_room_type&.lodging
    add_breadcrumb "#{@lodging_room_type} Room Options", convention_setup_lodging_room_type_path(@lodging_room_option.lodging_room_type) if @lodging_room_option&.lodging_room_type
  end

  def lodging_room_option_params
    params.require(:lodging_room_option).permit(:name, :price,
                                                lodging_days_attributes: %i[id _destroy date_offered])
  end
end
