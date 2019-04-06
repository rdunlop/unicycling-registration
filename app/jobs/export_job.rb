class ExportJob < ApplicationJob
  def perform(export_id)
    export = Export.find(export_id)

    exporter = case export.export_type
               when "results"
                 Exporters::ResultsExporter.new
               end

    return unless exporter

    headers = exporter.headers
    data = exporter.rows

    s = SpreadsheetCreator.new.create(headers, data)

    report = StringIO.new
    s.write report

    temp_file = Tempfile.new("results", Rails.root.join('tmp'), encoding: "binary").tap do |f|
      f.write(report.read)
      f.close
    end
    export.file = temp_file
    export.save!
    ExportCompleteMailer.send_export(export.id, "Results")
  end
end
