class PdfRenderer
  attr_accessor :view_target, :arguments

  def initialize(view_target, arguments = {})
    @view_target = view_target
    @arguments = arguments
  end

  def raw_pdf
    @controller = ApplicationController.new
    @controller.request = ActionDispatch::Request.new({})
    html_string = @controller.render_to_string(view_target, arguments)
    WickedPdf.new.pdf_from_string(html_string)
  end
end
