class EnteredDataExporter::Score
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    %w[judge_id judge_type_id registrant_external_id val1 val2 val3 val4]
  end

  def data
    competition.scores.map do |score|
      [score.judge.external_id,
       score.judge.judge_type.name,
       score.competitor.export_id, # use a single value even in groups
       score.val_1,
       score.val_2,
       score.val_3,
       score.val_4]
    end
  end
end
