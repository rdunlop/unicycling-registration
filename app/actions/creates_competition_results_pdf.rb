class CreatesCompetitionResultsPdf
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def results_raw_pdf
    renderer = PdfRenderer.new('printing/competitions/results', layout: 'pdf', locals: { :@competition => @competition })
    renderer.raw_pdf
  end

  def freestyle_summary_raw_pdf
    renderer = PdfRenderer.new('printing/competitions/freestyle_summary', layout: 'pdf', locals: { :@competition => @competition })
    renderer.raw_pdf
  end

  def publish!
    publish_result("#{sanitize(competition.to_s)}_results", results_raw_pdf)
    if competition.freestyle_summary?
      publish_result("#{sanitize(competition.to_s)}_freestyle_summary", freestyle_summary_raw_pdf, "Freestyle Summary")
    end
  end

  def publish_result(file_name, contents, custom_name = nil)
    pdf = Tempfile.new([file_name, '.pdf'], encoding: 'ascii-8bit')
    pdf.write contents
    new_result = competition.competition_results.build
    new_result.results_file = pdf
    new_result.published_date = Time.current
    new_result.system_managed = true
    new_result.published = true
    new_result.name = custom_name
    new_result.save!
    pdf.close
    pdf.unlink
    true
  end

  def unpublish!
    results = competition.competition_results.where(system_managed: true)
    results.destroy_all
    true
  end

  def sanitize(name)
    name.strip.gsub(/[^0-9A-Za-z.\-]/, '_')
  end
end
