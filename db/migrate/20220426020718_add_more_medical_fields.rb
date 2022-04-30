class AddMoreMedicalFields < ActiveRecord::Migration[5.2]
  def change
    add_column :registrants, :medical_certificate_uploaded_at, :datetime
    add_column :registrants, :medical_questionnaire_filled_out_at, :datetime
    add_column :registrants, :medical_questionnaire_attest_all_no_at, :datetime
  end
end
