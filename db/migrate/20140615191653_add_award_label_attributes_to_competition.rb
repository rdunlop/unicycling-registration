class AddAwardLabelAttributesToCompetition < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  class Competition < ActiveRecord::Base
    belongs_to :event

    def include_event_name
      case scoring_class
      when "Distance"
        false
      when "Ranked"
        false
      when "Freestyle"
        true
      when "Flatland"
        true
      when "Street"
        true
      when "Two Attempt Distance"
        false
      else
        false
      end
    end
  end

  def up
    add_column :competitions, :award_title_name, :string
    add_column :competitions, :award_subtitle_name, :string

    Competition.reset_column_information
    Competition.all.each do |competition|
      if competition.include_event_name
        competition.award_title_name = competition.event.name
        competition.award_subtitle_name = competition.name
        competition.name = competition.event.name + competition.name
      else
        competition.award_title_name = competition.name # These events have been 'fully named' (don't need the 'event' name)
      end

      competition.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
