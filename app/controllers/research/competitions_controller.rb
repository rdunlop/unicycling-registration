class Research::CompetitionsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource :research, class: false

  def index
    @tenants = Tenant.all
  end

  def competitions
    @competitions = Competition.all
  end
end
