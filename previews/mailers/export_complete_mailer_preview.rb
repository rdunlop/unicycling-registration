class ExportCompleteMailerPreview < ActionMailer::Preview
  def send_export
    export = Export.first
    ExportCompleteMailer.send_export(export.id, "Test Results")
  end
end
