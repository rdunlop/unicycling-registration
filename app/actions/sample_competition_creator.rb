class SampleCompetitionCreator
  attr_reader :competition_type

  def initialize(competition_type)
    @competition_type = competition_type
  end

  # Create a fake competition
  #
  # Returns true on success, false on error
  def create
    name = "#{competition_type} #{Faker::Hipster.word}"

    case competition_type
    when "Longest Time", "Shortest Time", "Timed Multi-Lap", "High/Long", "High/Long Final IUF 2015", "High/Long Preliminary IUF 2015"
      Competition.create!(
        name: name,
        event: Event.first,
        scoring_class: competition_type,
        award_title_name: name,
        age_group_type: age_group_type
      )
    when "Overall Champion"
      @errors = "This SampleData tool does not support Overall Champion Competitions"
      return false
    else
      Competition.create!(
        name: name,
        event: Event.first,
        scoring_class: competition_type,
        award_title_name: name
      )
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid.to_s
  end

  # return a list of errors, if any occurred
  def errors
    @errors
  end

  private

  def age_group_type
    if AgeGroupType.any?
      AgeGroupType.first
    else
      agt = FactoryGirl.create(:age_group_type)
      FactoryGirl.create(:age_group_entry, age_group_type: agt)
      FactoryGirl.create(:age_group_entry, :female, age_group_type: agt)
      agt
    end
  end
end
