class RemoveCompetitionReqFromUploadedFile < ActiveRecord::Migration[7.0]
  def up
    change_column_null :uploaded_files, :competition_id, true
  end

  def down
    change_column_null :uploaded_files, :competition_id, false
  end
end
