class CreateCompetitionResults < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
  end

  class CompetitionResult < ActiveRecord::Base
  end

  def up
    create_table :competition_results do |t|
      t.references :competition
      t.string :results_file
      t.boolean :system_managed
      t.boolean :published
      t.datetime :published_date
      t.timestamps
    end

    CompetitionResult.reset_column_information

    Competition.reset_column_information
    Competition.where(published: true).each do |competition|
      CompetitionResult.create!(
        competition_id: competition.id,
        published_date: competition.published_date,
        system_managed: true,
        published: true,
        results_file: competition.published_results_file
      )
    end

    remove_column :competitions, :published_date
    remove_column :competitions, :published_results_file
  end

  def down
    add_column :competitions, :published_date, :datetime
    add_column :competitions, :published_results_file, :string

    CompetitionResult.reset_column_information
    Competition.reset_column_information

    if CompetitionResult.where(system_managed: false).count.positive?
      raise "Unable to revert with non-system results"
    end

    CompetitionResult.all.each do |competition_result|
      competition = Competition.find(competition_result.competition_id)
      competition.update_attributes(
        published_results_file: competition_result.results_file,
        published_date: competition_result.published_date
      )
    end
    drop_table :competition_results
  end
end
