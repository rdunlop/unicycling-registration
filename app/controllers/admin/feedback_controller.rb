class Admin::FeedbackController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  before_action :load_feedback, only: [:show, :resolve]
  before_action :add_index_breadcrumb, except: [:index]

  # GET /admin/feedback/
  def index
    @feedbacks = Feedback.includes(:user, :resolved_by)

    respond_to do |format|
      format.html
    end
  end

  # GET /admin/feedback/new
  def new
    authorize current_user, :create_feedback?
    @feedback = Feedback.new
  end

  # POST /admin/feedback
  def create
    authorize current_user, :create_feedback?
    @feedback = Feedback.new(create_feedback_params)
    if @feedback.save
      flash[:notice] = "Feedback created successfully"
      redirect_to admin_feedback_index_path
    else
      flash[:alert] = "error creating feedback"
      render :new
    end
  end

  # GET /admin/feedback/:id
  def show
  end

  # PUT /admin/feedback/:id
  def resolve
    @feedback.resolution = params[:feedback][:resolution] if params[:feedback]
    @feedback.resolved_by = current_user

    if @feedback.resolve
      flash[:notice] = "Successfully resolved Feedback ##{@feedback.id}"
      redirect_to admin_feedback_index_path
    else
      flash[:alert] = "Unable to resolve feedback"
      redirect_to admin_feedback_path(@feedback)
    end
  end

  private

  def add_index_breadcrumb
    add_breadcrumb "All Feedback", admin_feedback_index_path
  end

  def create_feedback_params
    params.require(:feedback).permit(
      :user_id,
      :entered_email,
      :message,
      :status,
      :resolved_at,
      :resolved_by_id,
      :resolution,
      :created_at
    )
  end

  def load_feedback
    @feedback = Feedback.find(params[:id])
  end

  def authorize_user
    authorize current_user, :manage_feedback?
  end
end
