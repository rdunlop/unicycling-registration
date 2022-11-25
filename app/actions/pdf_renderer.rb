class PdfRenderer
  attr_accessor :view_target, :layout, :instance_variables, :pdf_options

  def initialize(view_target, layout:, instance_variables:, pdf_options:)
    @view_target = view_target
    @instance_variables = instance_variables
    @layout = layout
    @pdf_options = pdf_options
  end

  def raw_pdf
    lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)
    context = ActionView::Base.with_empty_template_cache.new(lookup_context, instance_variables, nil)
    renderer = ActionView::Renderer.new(lookup_context)

    html_string = renderer.render context, template: view_target, layout: "layouts/#{layout}"

    WickedPdf.new.pdf_from_string(html_string, pdf_options)
  end
end
