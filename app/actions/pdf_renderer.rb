class PdfRenderer
  attr_accessor :view_target, :layout, :instance_variables, :pdf_options

  def initialize(view_target, layout:, instance_variables:, pdf_options:)
    @view_target = view_target
    @instance_variables = instance_variables
    @layout = layout
    @pdf_options = pdf_options
  end

  def raw_pdf
    html_string = ApplicationController.render(
      template: view_target,
      layout: "layouts/#{layout}",
      assigns: instance_variables
    )

    WickedPdf.new.pdf_from_string(html_string, pdf_options)
  end
end
