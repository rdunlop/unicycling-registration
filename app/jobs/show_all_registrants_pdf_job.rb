# from https://github.com/mileszs/wicked_pdf/wiki/Background-PDF-creation-via-delayed_job-gem
class ShowAllRegistrantsPdfJob < ActiveJob::Base
  def perform(report_id, order, offset, max, current_user)
    report = Report.find(report_id)
    # create an instance of ActionView, so we can use the render method outside of a controller
    av = ActionView::Base.new
    av.view_paths = ActionController::Base.view_paths

    # The following 2 lines, plus the passing of `@current_user` as a local,
    # allow Pundit to access the user which invoked this job
    @current_user = current_user
    ActionView::Base.send(:define_method, :current_user) { @current_user }
    # need these in case your view constructs any links or references any helper methods.
    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
      include Pundit
    end

    if order.present? && order == "id"
      @registrants = Registrant.active.reorder(:bib_number)
    else
      @registrants = Registrant.active.reorder(:sorted_last_name, :first_name)
    end

    if offset
      @registrants = @registrants.limit(max).offset(offset)
    end

    pdf_html = av.render template: "admin/registrants/show_all.pdf.haml", layout: "layouts/pdf.html.haml", locals: {:@registrants => @registrants, :@config => EventConfiguration.singleton, :@current_user => current_user}

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(pdf_html, page_size: 'Letter')

    file = Tempfile.open(["show_all", ".pdf"])
    file.binmode
    begin
      file.write doc_pdf
      file.close
      report.url = file
      report.completed_at = DateTime.current
      report.save!
    ensure
      file.close
      file.unlink
    end
  end
end
