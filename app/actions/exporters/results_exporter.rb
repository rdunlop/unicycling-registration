class Exporters::ResultsExporter
  def headers
    ["ID", "Name", "Gender", "Age", "Competition", "Place", "Result Type", "Result", "Details", "Age Group"]
  end

  def rows
    data = []
    Result.includes(
      competitor: [competition: [],
                   members: [
                     registrant: [:competition_wheel_sizes]],
                   external_result: [],
                   time_results: [],
                   distance_attempts: [],
                   scores: []]).all.find_each(batch_size: 100) do |result|
      data << [
        result.competitor.bib_number,
        result.competitor.to_s,
        result.competitor.gender,
        result.competitor.age,
        result.competitor.competition.award_title,
        result.to_s,
        result.result_type,
        result.competitor.result,
        result.competitor.details,
        result.competitor.age_group_entry_description
      ]
    end

    data
  end
end
