class UsaMembershipsController < ApplicationController
  authorize_resource class: false

  before_action :load_usa_paid_registrants

  def index
  end

  def update
    @registrant = Registrant.find(params[:registrant_id])
    cd = @registrant.contact_detail

    if params[:external_confirm]
      cd.update_attribute(:usa_confirmed_paid, true)
      flash[:notice] = "Marked #{@registrant} as confirmed"
    elsif params[:family_membership_registrant_id]
      cd.update_attribute(:usa_family_membership_holder_id, params[:family_membership_registrant_id])
      flash[:notice] = "Marked #{@registrant} as family-member"
    else
      flash[:alert] = "unknown action"
    end

    respond_to do |format|
      format.html { redirect_to usa_memberships_path }
      format.js {}
    end
  end

  private

  def load_usa_paid_registrants
    family_item = EventConfiguration.usa_family_expense_item
    individual_item = EventConfiguration.usa_individual_expense_item

    @family_registrants = family_item.payment_details.includes(:registrant).paid.map{|pd| pd.registrant}
    @individual_registrants = individual_item.payment_details.includes(:registrant).paid.map{|pd| pd.registrant}
  end
end
