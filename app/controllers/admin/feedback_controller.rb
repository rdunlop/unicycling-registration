class Admin::FeedbackController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  before_action :load_feedback, only: [:show, :resolve]

  # GET /admin/feedback/
  def index
    @feedbacks = Feedback.includes(:user, :resolved_by)

    respond_to do |format|
      format.html
    end
  end

  # GET /admin/feedback/:id
  def show
    add_breadcrumb "All Feedback", admin_feedback_index_path
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

  def load_feedback
    @feedback = Feedback.find(params[:id])
  end

  def authorize_user
    authorize current_user, :manage_feedback?
  end
end
