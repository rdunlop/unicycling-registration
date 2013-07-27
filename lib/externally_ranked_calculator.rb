class ExternallyRankedCalculator

  def initialize(competition)
    @competition = competition
  end

  # update the places for all age groups
  def update_all_places
    age_group_type = @competition.determine_age_group_type
    unless age_group_type.nil?
      age_group_type.age_group_entries.each do |age|
        update_places(age.to_s)
      end
    end
    update_overall_places("Male")
    update_overall_places("Female")
  end


  private
  # update the places for an event, fastest first.
  # DQ are marked as place = 0
  # results with time==0 are marked as place = 0
  def update_places(age_group_entry_description)
    return 0 if age_group_entry_description.nil?

    rank = 1
    @competition.external_results.order("rank").each do |er|

      # only perform updates on the specified age group entry set
      next if er.competitor.age_group_entry_description != age_group_entry_description

      er.competitor.place = rank
      rank += 1
    end
  end

  def update_overall_places(gender)

    rank = 1
    @competition.external_results.order("rank").each do |er|
      next if er.competitor.gender != gender

      er.competitor.overall_place = rank
      rank += 1
    end
  end
end
