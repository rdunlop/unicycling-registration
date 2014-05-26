class AddFieldsToImportResults < ActiveRecord::Migration
  class ImportResult < ActiveRecord::Base
  end

  def up
    add_column :import_results, :attempt_number, :integer
    add_column :import_results, :status, :string
    add_column :import_results, :comments, :text

    ImportResult.reset_column_information

    ImportResult.where(disqualified: true).each do |import_result|
      import_result.update_attribute(:status, "DQ")
    end

    remove_column :import_results, :disqualified
  end

  def down
    add_column :import_results, :disqualified, :boolean

    ImportResult.reset_column_information

    ImportResult.where(status: "DQ").each do |import_result|
      import_result.update_attribute(:disqualified, true)
    end

    remove_column :import_results, :attempt_number
    remove_column :import_results, :status
    remove_column :import_results, :comments
  end
end
