class CreatesCompetitionResultsPdf
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def raw_pdf
    @controller = ApplicationController.new
    @controller.request = ActionDispatch::Request.new({})
    html_string = @controller.render_to_string('printing/competitions/results', layout: 'pdf', locals: { :@competition => @competition })
    WickedPdf.new.pdf_from_string(html_string)
  end

  def publish!
    pdf = Tempfile.new(["#{sanitize(competition.to_s)}_results", '.pdf'], encoding: 'ascii-8bit')
    pdf.write raw_pdf
    new_result = competition.competition_results.build
    new_result.results_file = pdf
    new_result.published_date = DateTime.current
    new_result.system_managed = true
    new_result.published = true
    new_result.save!
    pdf.close
    pdf.unlink
    true
  end

  def unpublish!
    result = competition.competition_results.where(system_managed: true).first
    result&.destroy
    true
  end

  def sanitize(name)
    name.strip.gsub(/[^0-9A-Za-z.\-]/, '_')
  end
end
