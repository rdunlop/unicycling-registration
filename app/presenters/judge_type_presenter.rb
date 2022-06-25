class JudgeTypePresenter
  include ApplicationHelper

  def initialize(judge_type)
    @judge_type = judge_type
  end

  # MUST be 2 words (see place where this is used)
  def total_header_words
    case judge_type.name
    when "Artistic Freestyle IUF 2019"
      ["Avg.", "Perc."]
    else
      ["Total", "Points"]
    end
  end
end
