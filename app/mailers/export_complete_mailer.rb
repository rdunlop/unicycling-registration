class ExportCompleteMailer < TenantAwareMailer
  def send_export(export_id, title)
    @export = Export.find(export_id)

    mail to: @export.exported_by.email,
         subject: "Your #{title} Export is ready"
  end
end
