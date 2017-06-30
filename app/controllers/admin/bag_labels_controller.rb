class Admin::BagLabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_access
  def index; end

  def create
    @registrants = Registrant.includes(:contact_detail).reorder(:sorted_last_name, :first_name).active.all
    if params[:display_expenses]
      @registrants = @registrants.includes(:expense_items)
    end

    names = []

    @registrants.find_each do |reg|
      record = "\n"
      record += "<b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name}\n"
      record += "#{reg.representation}\n"
      record += reg.registrant_type.capitalize.to_s

      if params[:display_expenses]
        reg_summary = reg.expense_items.map(&:name).join(", ")
        record += "\n<b>Items:</b> #{reg_summary}" if reg_summary.present?
      end
      names << record
    end

    labels = Prawn::Labels.render(names, type: "Avery5160", shrink_to_fit: true) do |pdf, name|
      set_font(pdf)

      pdf.text name, align: :center, inline_format: true
    end

    send_data labels, filename: "bag-labels-#{Date.today}.pdf", type: "application/pdf"
  end

  private

  def authorize_access
    authorize current_user, :registrant_information?
  end
end
