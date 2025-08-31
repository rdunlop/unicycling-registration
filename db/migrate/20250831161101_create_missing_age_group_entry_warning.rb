class CreateMissingAgeGroupEntryWarning < ActiveRecord::Migration[7.1]
  def change
    create_table :missing_age_group_entry_warnings do |t|
      t.references :competition, index: { name: "cmagew_competition" }
      t.references :competitor, index: { name: "cmagew_competitor" }
      t.timestamps
    end
  end
end
