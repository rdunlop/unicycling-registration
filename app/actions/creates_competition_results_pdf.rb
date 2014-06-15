class CreatesCompetitionResultsPdf
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  def raw_pdf
    @controller = ApplicationController.new
    @controller.request = ActionDispatch::Request.new({})
    html_string = @controller.render_to_string('printing/competitions/results', layout: 'pdf', locals: { :@competition => @competition })
    res = WickedPdf.new.pdf_from_string(html_string)
  end

  def publish!
    pdf = Tempfile.new(["#{competition}_results", '.pdf'], encoding: 'ascii-8bit')
    pdf.write raw_pdf
    competition.published_results_file = pdf
    competition.save!
    pdf.close
    pdf.unlink
    true
  end

  def unpublish!
    competition.remove_published_results_file!
  end
end
