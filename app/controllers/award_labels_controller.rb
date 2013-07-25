class AwardLabelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create, :create_labels, :expert_labels, :normal_labels, :destroy_all]

  def load_user
    @user = User.find(params[:user_id])
  end

  # GET /users/#/award_labels
  # GET /users/#/award_labels.json
  def index
    @award_labels = AwardLabel.all
    @award_label = AwardLabel.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @award_labels }
    end
  end

  # GET /award_labels/1/edit
  def edit
    @award_label = AwardLabel.find(params[:id])
    @user = @award_label.user
  end

  # POST /users/#/award_labels
  # POST /users/#/award_labels.json
  def create
    @award_label = AwardLabel.new(params[:award_label])
    @award_label.user = @user

    respond_to do |format|
      if @award_label.save
        format.html { redirect_to user_award_labels_path(@user), notice: 'Award label was successfully created.' }
      else
        @award_labels = @user.award_labels
        format.html { render action: "index" }
      end
    end
  end

  # PUT /award_labels/1
  # PUT /award_labels/1.json
  def update
    @award_label = AwardLabel.find(params[:id])

    respond_to do |format|
      if @award_label.update_attributes(params[:award_label])
        format.html { redirect_to user_award_labels_path(@award_label.user), notice: 'Award label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @award_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /award_labels/1
  # DELETE /award_labels/1.json
  def destroy
    @award_label = AwardLabel.find(params[:id])
    @user = @award_label.user
    @award_label.destroy

    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user) }
      format.json { head :no_content }
    end
  end
end
