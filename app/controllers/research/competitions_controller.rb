class Research::CompetitionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def index
    @tenants = Tenant.all
  end

  def competitions
    @competitions = Competition.all
  end

  private

  def authorize_user
    authorize current_user, :under_development?
  end
end
