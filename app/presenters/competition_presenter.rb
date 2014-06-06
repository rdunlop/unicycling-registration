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
    when "unawarded"
      "Not Awarded"
    when "awarded"
      "Complete"
    end
  end

  def status_code
    return "no_competitors" if competition.competitors.count == 0
    return "no_results" if competition.num_results == 0
    return "unawarded" if true
    return "awarded" if true # XXX to be added once we have these states
  end

end
