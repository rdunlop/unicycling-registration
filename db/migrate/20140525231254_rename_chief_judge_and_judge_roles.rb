class RenameChiefJudgeAndJudgeRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base
  end
  def up
    Role.reset_column_information

    chief = Role.find_by(name: "chief_judge")
    if chief
      chief.name = "director"
      chief.save!
    end

    judge = Role.find_by(name: "judge")
    if judge
      judge.name = "data_entry_volunteer"
      judge.save!
    end
  end

  def down
    Role.reset_column_information

    director = Role.find_by(name: "director")
    if director
      director.name = "chief_judge"
      director.save!
    end

    data_entry_volunteer = Role.find_by(name: "data_entry_volunteer")
    if data_entry_volunteer
      data_entry_volunteer.name = "judge"
      data_entry_volunteer.save!
    end
  end
end
