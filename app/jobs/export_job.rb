class ExportJob < ApplicationJob
  class FileIO < StringIO
    def initialize(stream, filename)
      super(stream)
      @original_filename = filename
    end

    attr_reader :original_filename
  end

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
    report.binmode
    s.write report

    export.file = FileIO.new(report.string, "#{export.export_type}_#{Time.current.iso8601}.xls")
    export.save!
    ExportCompleteMailer.send_export(export.id, "Results").deliver_later
  end
end
