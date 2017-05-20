class EnteredDataExporter::MaxDistance
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    %w[registrant_external_id distance]
  end

  def data
    competition.competitors.map do |comp|
      if comp.has_result?
        [comp.export_id,
         comp.result]
      end
    end.compact
  end
end
