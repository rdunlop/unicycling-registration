class EnteredDataExporter::Time
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def headers
    %w(registrant_external_id gender age heat lane thousands result)
  end

  def data
    competition.competitors.map do |comp|
      next unless comp.has_result?
      tr = comp.time_results.first
      heat = tr.heat_lane_result

      [comp.export_id,
       comp.gender,
       comp.age,
       heat.try(:heat),
       heat.try(:lane),
       comp.best_time_in_thousands,
       comp.result]
    end.compact
  end
end
