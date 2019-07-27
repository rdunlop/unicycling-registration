class AddInfoPagesAndAdjustMedicalCert < ActiveRecord::Migration[5.1]
  def change
    rename_column :event_configurations, :require_medical_document, :require_medical_certificate
    rename_column :registrants, :medical_document, :medical_certificate
    add_column :event_configurations, :medical_certificate_info_page_id, :integer
    add_column :event_configurations, :volunteer_option_page_id, :integer
    add_column :pages, :visible, :boolean, default: true, null: false
  end
end
