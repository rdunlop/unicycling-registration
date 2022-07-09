class AddMedicalCertificateReviewed < ActiveRecord::Migration[5.2]
  def change
    add_column :registrants, :medical_certificate_manually_confirmed, :boolean, null: false, default: false
  end
end
