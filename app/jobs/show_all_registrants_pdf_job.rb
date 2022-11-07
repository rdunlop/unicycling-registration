# from https://github.com/mileszs/wicked_pdf/wiki/Background-PDF-creation-via-delayed_job-gem

# Based on https://stackoverflow.com/questions/28332630/rails-render-view-from-outside-controller#answer-70027370
class PdfRegistrantView < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include Pundit::Authorization

  def compiled_method_container
    self.class
  end

  # Passed in as instance variable to ActionView::Base.new
  attr_reader :current_user

  def url_options
    { locale: I18n.locale }.merge(super)
  end
end

class ShowAllRegistrantsPdfJob < ApplicationJob
  def perform(report_id, order, offset, max, current_user)
    report = Report.find(report_id)

    # create an instance of ActionView, so we can use the render method outside of a controller
    lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)

    if order.present? && order == "id"
      registrants = Registrant.active.reorder(:bib_number)
    else
      registrants = Registrant.active.reorder(:sorted_last_name, :first_name)
    end

    if offset.present? && max.present?
      registrants = registrants.limit(max).offset(offset)
    end

    context = PdfRegistrantView.new(lookup_context, {
                                      registrants: registrants,
                                      config: EventConfiguration.singleton,
                                      current_user: current_user
                                    }, nil)

    context.load_config_object_and_i18n
    renderer = ActionView::Renderer.new(lookup_context)
    pdf_html = renderer.render context, template: "admin/registrants/show_all", format: "pdf", layout: "layouts/pdf"

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'Letter')

    file = Tempfile.open(["show_all", ".pdf"])
    file.binmode
    begin
      file.write doc_pdf
      file.close
      report.url = file
      report.completed_at = Time.current
      report.save!
    ensure
      file.close
      file.unlink
    end
  end
end
