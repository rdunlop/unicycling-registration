class CreateCompetitionSourceModel < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
    has_many :competition_sources
  end

  class CompetitionSource < ActiveRecord::Base
    belongs_to :target_competition, class_name: "Competition"
    belongs_to :event_category
    belongs_to :competition
  end

  def up
    create_table :competition_sources do |t|
      t.integer :target_competition_id
      t.integer :event_category_id
      t.integer :competition_id
      t.string  :gender_filter
      t.integer :max_place
      t.timestamps
    end

    add_index :competition_sources, ["competition_id"], name: "index_competition_sources_competition_id"
    add_index :competition_sources, ["event_category_id"], name: "index_competition_sources_event_category_id"
    add_index :competition_sources, ["target_competition_id"], name: "index_competition_sources_target_competition_id"

    CompetitionSource.reset_column_information
    Competition.reset_column_information

    Competition.all.each do |competition|
      cs = CompetitionSource.new(
        target_competition_id: competition.id,
        gender_filter: competition.gender_filter,
        event_category_id: competition.event_category_id
      )
      cs.save!
    end

    remove_column :competitions, :gender_filter
    remove_column :competitions, :event_category_id
  end

  def down
    CompetitionSource.reset_column_information

    add_column :competitions, :gender_filter, :string
    add_column :competitions, :event_category_id, :integer
    Competition.reset_column_information

    CompetitionSource.all.each do |cs|
      c = cs.target_competition
      c.event_category_id = cs.event_category_id
      c.gender_filter = cs.gender_filter
      c.save!
    end

    drop_table :competition_sources
  end
end
