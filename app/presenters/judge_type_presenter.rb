class JudgeTypePresenter
  include ApplicationHelper

  attr_reader :judge_type

  def initialize(judge_type)
    @judge_type = judge_type
  end

  # MUST be 2 words (see place where this is used)
  def total_header_words
    case judge_type.event_class
    when "Artistic Freestyle IUF 2019"
      ["Avg.", "Perc."]
    else
      ["Total", "Points"]
    end
  end
end
