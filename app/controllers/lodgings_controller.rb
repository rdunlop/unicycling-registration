class LodgingsController < ApplicationController
  before_action :load_registrant

  def create
    authorize @registrant, :lodging?

    form = LodgingForm.new(lodging_params.merge(registrant_id: @registrant.id))
    if form.save
      flash[:notice] = "Lodging Added"
    else
      flash[:alert] = "Error adding lodging. #{form.errors.full_messages.join(', ')}"
    end
    redirect_to registrant_build_path(@registrant, "lodging")
  end

  private

  def load_registrant
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end

  def lodging_params
    params.require(:lodging_form).permit(:lodging_room_option_id, :check_in_day, :check_out_day)
  end
end
