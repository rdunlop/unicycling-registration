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
    res = raw_pdf
    pdf = Tempfile.new(["#{competition}_results", '.pdf'], encoding: 'ascii-8bit')
    pdf.write res
    competition.published_results_file = pdf
    competition.save!
    pdf.close
    pdf.unlink
    true
  end
end
