class Exporters::WaveExporter
  def initialize(competitors)
    @competitors = competitors
  end

  def headers
    ["ID", "Wave", "Name", "Age", "Gender", "Age Group", "Best Time"]
  end

  def rows
    results = []
    @competitors.each do |comp|
      results << [
        comp.lowest_member_bib_number,
        comp.wave,
        comp.detailed_name,
        comp.age,
        comp.gender,
        comp.age_group_entry_description,
        comp.best_time
      ]
    end

    results
  end
end
