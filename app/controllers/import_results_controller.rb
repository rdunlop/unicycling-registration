class ImportResultsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create]

  def load_user
    @user = User.find(params[:user_id])
  end

  # GET /import_results
  # GET /import_results.json
  def index
    @import_results = @user.import_results.all
    @import_result = ImportResult.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_results }
    end
  end

  # GET /import_results/1
  # GET /import_results/1.json
  def show
    @import_result = ImportResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import_result }
    end
  end

  # GET /import_results/1/edit
  def edit
    @import_result = ImportResult.find(params[:id])
  end

  # POST /import_results
  # POST /import_results.json
  def create
    @import_result = ImportResult.new(params[:import_result])
    @import_result.user = @user

    respond_to do |format|
      if @import_result.save
        format.html { redirect_to user_import_results_path(@user), notice: 'Import result was successfully created.' }
      else
        @import_results = @user.import_results
        format.html { render action: "index" }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update
    @import_result = ImportResult.find(params[:id])

    respond_to do |format|
      if @import_result.update_attributes(params[:import_result])
        format.html { redirect_to user_import_results_path(@import_result.user), notice: 'Import result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_results/1
  # DELETE /import_results/1.json
  def destroy
    @import_result = ImportResult.find(params[:id])
    user = @import_result.user
    @import_result.destroy

    respond_to do |format|
      format.html { redirect_to user_import_results_path(user) }
      format.json { head :no_content }
    end
  end
end
