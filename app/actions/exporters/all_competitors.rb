class Exporters::AllCompetitors
  def headers
    ['bib_number', 'last_name', 'first_name', 'country']
  end

  def rows
    Registrant.active.competitor.map do |registrant|
      [
        registrant.bib_number,
        ActiveSupport::Inflector.transliterate(registrant.last_name),
        ActiveSupport::Inflector.transliterate(registrant.first_name),
        registrant.country
      ]
    end
  end
end
