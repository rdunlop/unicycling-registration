class Admin::RegistrantSummariesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_access

  # GET /registrant_summaries
  def index; end

  # POST /registrant_summaries
  def create
    report = Report.create!(report_type: "registration_summary")
    ShowAllRegistrantsPdfJob.perform_later(report.id, params[:order], params[:offset], params[:limit], current_user)

    redirect_to reports_path, notice: "Report Generation started. Check back in a few minutes"
  end

  private

  def authorize_access
    authorize current_user, :registrant_information?
  end
end
