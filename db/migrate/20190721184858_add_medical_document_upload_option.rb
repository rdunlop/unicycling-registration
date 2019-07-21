class AddMedicalDocumentUploadOption < ActiveRecord::Migration[5.1]
  def change
    add_column :registrants, :medical_document, :string
    add_column :event_configurations, :require_medical_document, :boolean, default: false, null: false
  end
end
