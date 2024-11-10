class UpdatePapertrailStorage < ActiveRecord::Migration[7.0]
  def up
    add_column :versions, :new_object, :json
    add_column :versions, :new_object_changes, :json

    # PaperTrail::Version.reset_column_information # needed for rails < 6

    PaperTrail::Version.find_each do |version|
      version.update_column(:new_object, YAML.unsafe_load(version.object)) if version.object?

      if version.object_changes
        version.update_column(
          :new_object_changes,
          YAML.unsafe_load(version.object_changes)
        )
      end
    end

    # Remove old data:
    remove_column :versions, :object
    remove_column :versions, :object_changes

    # Rename new columns to correct(expected) names
    rename_column :versions, :new_object, :object
    rename_column :versions, :new_object_changes, :object_changes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
