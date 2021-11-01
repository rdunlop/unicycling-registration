class Admin::ApiTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_api_admin

  # GET /admin/api_tokens
  def index
    @tokens = ApiToken.all.order(:created_at)
  end

  def new
    @token = ApiToken.new
  end

  # POST /admin/api_tokens
  def create
    @token = ApiToken.new(api_token_params)
    if @token.save
      flash[:notice] = "Token created"
      redirect_to api_tokens_path
    else
      flash.now[:alert] = "Unable to create token"
      render :new
    end
  end

  def destroy
    @token = ApiToken.find(params[:id])

    @token.destroy
    flash[:notice] = "Token deleted"
    redirect_to api_tokens_path
  end

  private

  def api_token_params
    params.require(:api_token).permit(:description)
  end

  def authorize_api_admin
    authorize current_user, :manage_api_tokens?
  end
end
