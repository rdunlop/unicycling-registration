class Registrants::BuildController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!
  load_and_authorize_resource :user

  steps :add_name, :add_events, :add_volunteers

  before_action :load_registrant, only: [:show, :update]

  def show
    render_wizard
  end


  def update
    #params[:registrant][:status] = step.to_s
    #params[:registrant][:status] = 'active' if step == steps.last
    @registrant.update_attributes(params[:registrant])
    render_wizard @registrant
  end


  def create
    @registrant = Registrant.create
    redirect_to wizard_path(steps.first, :registrant_id => @registrant.id)
  end

  private

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end
end
