class LodgingPackagesController < ApplicationController
  before_action :load_registrant

  # /:registrant_id/lodging_packages/:lodging_package_id
  def destroy
    authorize @registrant, :lodging?

    lodging_package = LodgingPackage.find(params[:id])
    package = @registrant.registrant_expense_items.find_by(line_item: lodging_package)
    if package&.destroy && lodging_package.destroy
      flash[:notice] = "Lodging Removed"
    else
      flash[:alert] = "Error removing lodging"
    end
    redirect_to registrant_build_path(@registrant, "lodging")
  end

  private

  def load_registrant
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end
end
