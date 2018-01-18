class LodgingPackagesController < ApplicationController
  before_action :load_registrant

  # /:registrant_id/lodging_packages/:lodging_package_id
  def destroy
    authorize @registrant, :lodging?

    lodging_package = LodgingPackage.find(params[:id])
    package = @registrant.registrant_expense_items.find_by(line_item: lodging_package)
    if package&.destroy
      # This does sort-of orphan LodgingPackages if the registrant drafts a payment
      # and never completes it, but, this isn't a big problem, since it's rare,
      # and we actually never delete draft Payments, so there's always a reference
      lodging_package.destroy unless lodging_package.payment_details.any?
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
