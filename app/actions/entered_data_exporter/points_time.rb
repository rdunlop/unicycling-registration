class EnteredDataExporter::PointsTime
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    %w[registrant_external_id gender age result]
  end

  def data
    competition.competitors.map do |comp|
      next unless comp.has_result?

      [comp.export_id,
       comp.gender,
       comp.age,
       comp.result]
    end.compact
  end
end
