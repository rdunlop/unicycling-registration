class MoveEventCategoryAssociationIntoCompetition < ActiveRecord::Migration
  class Competition < ActiveRecord::Base
    has_one :event_category
  end

  class EventCategory < ActiveRecord::Base
    belongs_to :competition
  end

  def up
    add_column :competitions, :event_category_id, :integer
    Competition.reset_column_information

    Competition.all.each do |competition|
      ec = competition.event_category
      unless ec.nil?
        competition.event_category_id = ec.id
        competition.save
      end
    end

    remove_column :event_categories, :competition_id
    EventCategory.reset_column_information
  end

  def down
    add_column :event_categories, :competition_id, :integer
    EventCategory.reset_column_information

    Competition.all.each do |competition|
      ec_id = competition.event_category_id
      unless ec_id.nil?
        ec = EventCategory.find(ec_id)
        ec.competition = competition
        ec.save
      end
    end

    remove_column :competitions, :event_category_id
  end
end
