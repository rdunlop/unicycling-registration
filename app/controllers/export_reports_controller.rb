class ExportReportsController < ApplicationController
  before_action :authenticate_user!

  def create
    export_type = params[:export_type]

    redirect_back(fallback_location: export_index_path, alert: "Invalid export_type") unless export_type == "results"

    export = Export.create!(
      exported_by: current_user,
      export_type: export_type
    )
    authorize export
    ExportJob.perform_later(export.id)
    redirect_back(fallback_location: export_index_path, notice: "Email processing....")
  end

  def show
    export = Export.find(params[:id])
    authorize export
    send_data export.file, filename: "#{export.type}.xls"
  end
end
