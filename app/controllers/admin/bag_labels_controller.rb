class Admin::BagLabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_access
  def index; end

  def create
    @registrants = Registrant.includes(:contact_detail).reorder(:sorted_last_name, :first_name).active.all
    if params[:display_expenses]
      @registrants = @registrants.includes(:expense_items)
    end

    label_type = params[:label_type] || "Avery5160"

    names = []

    label_per_registrant = (params[:num_per_reg].presence || 1).to_i
    @registrants.each do |reg|
      label_per_registrant.times do
        record = ""
        record += "<b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name}\n"
        record += "#{reg.representation}\n" if params[:show_country]
        record += reg.registrant_type.capitalize.to_s

        if params[:display_expenses]
          reg_summary = reg.expense_items.map(&:name).join(", ")
          record += "\n<b>Items:</b> #{reg_summary}" if reg_summary.present?
        end
        names << record
      end
    end

    labels = Prawn::Labels.render(names, type: label_type, shrink_to_fit: true) do |pdf, name|
      set_font(pdf)

      pdf.text name, align: :center, inline_format: true, fallback_fonts: ["IPA"]
    end

    send_data labels, filename: "bag-labels-#{Date.current}.pdf", type: "application/pdf"
  end

  private

  def authorize_access
    authorize current_user, :registrant_information?
  end
end
