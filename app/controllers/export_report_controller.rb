class ExportReportController < ApplicationController
  before_action :authenticate_user!

  def send_email
    export = Export.create!(
      exported_by: current_user,
      export_type: "results"
    )
    authorize export
    ExportJob.perform_later(export.id)
    redirect_back(fallback_location: export_index_path, notice: "Email processing....")
  end

  def download_file
    export = Export.find(params[:export_report_id])
    authorize export
    send_data export.file, filename: "#{export.type}.xls"
  end
end
