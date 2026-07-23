class Admin::BagLabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_access
  before_action :load_label_definitions, only: [:index]
  before_action :load_prawn_label_types, only: [:create]

  def index; end

  def create
    if params[:label_type].blank?
      redirect_to bag_labels_path, alert: "Please choose a label type."
      return
    end

    @registrants = Registrant.includes(:contact_detail).reorder(:bib_number).active.all
    if params[:display_expenses]
      @registrants = @registrants.includes(:expense_items)
    end

    label_type = params[:label_type]

    names = []

    label_per_registrant = (params[:num_per_reg].presence || 1).to_i
    @registrants.each do |reg|
      label_per_registrant.times do
        record = "<b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name}"
        record += "\n#{reg.representation}" if params[:show_country]
        record += "\n#{reg.registrant_type.capitalize}"

        if params[:display_expenses]
          reg_summary = reg.expense_items.map(&:name).join(", ")
          record += "\n<b>Items:</b> #{reg_summary}" if reg_summary.present?
        end
        names << record
      end
    end

    labels = Prawn::Labels.render(names, type: label_type, shrink_to_fit: true) do |pdf, name|
      set_font(pdf)

      pdf.text name, align: :center, inline_format: true, valign: :center, fallback_fonts: ["IPA"]
    end

    send_data labels, filename: "bag-labels-#{Date.current}.pdf", type: "application/pdf"
  end

  private

  def authorize_access
    authorize current_user, :registrant_information?
  end

  def load_prawn_label_types
    LabelTypeRegistry.load_into_prawn!
  end

  def load_label_definitions
    @label_types = (SystemLabelType.order(:name) + CustomLabelType.order(:name)).map do |label_type|
      { name: label_type.name, description: label_type.description }
    end
  end
end
