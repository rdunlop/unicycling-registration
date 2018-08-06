class Exporters::TierExporter
  def initialize(competitors)
    @competitors = competitors
  end

  def headers
    ["Id", "Tier", "Tier Description", "Name", "Age", "Gender"]
  end

  def rows
    results = []
    @competitors.each do |comp|
      results << [
        comp.lowest_member_bib_number,
        comp.tier_number,
        comp.tier_description,
        comp.detailed_name,
        comp.age,
        comp.gender
      ]
    end

    results
  end
end
