class CompetitionPresenter
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def status
    # this should be a state-machine?
    case status_code
    when "no_competitors"
      "No Competitors Defined"
    when "no_results"
      "No Results Found"
  #  when "unconfirmed_results"
    when "incomplete"
      "Results Incomplete"
    when "complete"
      "Results Completed (unpublished)"
    when "published"
      "Results Published"
    when "awarded"
      "Complete (Awarded)"
    end
  end

  def status_code
    return "no_competitors" if competition.competitors.count == 0
    return "no_results" if competition.num_results == 0
    return "incomplete" if !competition.locked?
    return "complete" if !competition.published?
    return "published" if competition.published? && !competition.awarded?
    return "awarded" if competition.awarded?
  end
end
