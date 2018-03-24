class StylesController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization

  def index; end
end
