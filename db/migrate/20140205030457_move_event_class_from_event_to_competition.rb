class MoveEventClassFromEventToCompetition < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
    belongs_to :event
  end
  class Event < ActiveRecord::Base
    has_many :competitions
  end

  def up
    add_column :competitions, :scoring_class, :string

    Competition.reset_column_information
    Event.reset_column_information

    Competition.all.each do |competition|
      e = competition.event
      if e.nil? or e.event_class.nil?
        competition.scoring_class = "Ranked"
      else
        competition.scoring_class = e.event_class
      end
      competition.save
    end

    remove_column :events, :event_class
  end

  def down
    add_column :events, :event_class, :string

    Competition.reset_column_information
    Event.reset_column_information

    Competition.all.each do |competition|
      e = competition.event
      unless e.nil? or competition.scoring_class.nil?
        e.event_class = competition.scoring_class
        e.save
      end
    end

    remove_column :competitions, :scoring_class
  end
end
