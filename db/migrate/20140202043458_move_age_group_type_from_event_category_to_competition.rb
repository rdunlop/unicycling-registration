class MoveAgeGroupTypeFromEventCategoryToCompetition < ActiveRecord::Migration
  class EventCategory < ActiveRecord::Base
     belongs_to :age_group_type
     belongs_to :competition
  end
  class Competition < ActiveRecord::Base
    belongs_to :age_group_type
    has_one :event_category
  end

  def up
    EventCategory.reset_column_information
    Competition.reset_column_information

    Competition.all.each do |competition|
      if competition.age_group_type.nil?
        ec = competition.event_category
        unless ec.nil?
          competition.age_group_type = ec.age_group_type
          competition.save
        end
      end
    end
    remove_column :event_categories, :age_group_type_id
  end

  def down
    add_column :event_categories, :age_group_type_id
  end
end
