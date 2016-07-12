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
    when "Longest Time", "Shortest Time", "Shortest Time with Tiers", "Timed Multi-Lap", "High/Long", "High/Long Final IUF 2015", "High/Long Preliminary IUF 2015"
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
      agt = AgeGroupType.create!(name: "Sample Age Group", description: "For testing")
      AgeGroupEntry.create!(age_group_type: agt, short_description: "Men", start_age: 0, end_age: 100, gender: "Male", position: 1)
      AgeGroupEntry.create!(age_group_type: agt, short_description: "Women", start_age: 0, end_age: 100, gender: "Female", position: 2)
      agt
    end
  end
end
