class CreateAgeGroupType < ActiveRecord::Migration
  def change
    create_table :age_group_types do |t|
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table :age_group_entries do |t|
      t.integer :age_group_type_id
      t.string :short_description
      t.string :long_description
      t.integer :start_age
      t.integer :end_age
      t.string :gender
      t.timestamps
    end
  end
end
