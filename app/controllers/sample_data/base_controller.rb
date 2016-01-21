class SampleData::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_access

  layout "sample_data"

  private

  def authorize_access
    authorize :sample_data, :create?
  end
end
