class Exporters::WaveExporter
  def initialize(competitors)
    @competitors = competitors
  end

  def headers
    ["ID", "Wave", "Name"]
  end

  def rows
    results = []
    @competitors.each do |comp|
      results << [
        comp.lowest_member_bib_number,
        comp.wave,
        comp.detailed_name
      ]
    end

    results
  end
end
