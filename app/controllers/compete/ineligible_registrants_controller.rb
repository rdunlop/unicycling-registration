class Compete::IneligibleRegistrantsController < ApplicationController
  before_action :authenticate_ability

  before_action :load_registrant, except: :index

  respond_to :html

  def index
    @ineligible_registrants = Registrant.where(ineligible: true)
    @registrants = Registrant.active
  end

  def create
    if @registrant.update_attribute(:ineligible, true)
      flash[:notice] = "Registrant #{@registrant} has been marked ineligible"
      redirect_to ineligible_registrants_path
    else
      index
      render :index
    end
  end

  def destroy
    @registrant.update_attribute(:ineligible, false)
    flash[:notice] = "Registrant #{@registrant} has been marked eligible"
    redirect_to ineligible_registrants_path
  end

  private

  def authenticate_ability
    authorize @config, :setup_competition?
  end

  def load_registrant
    # 'create' uses :registrant_id
    # 'destroy' uses :id
    @registrant = Registrant.find(params[:registrant_id] || params[:id])
  end
end
