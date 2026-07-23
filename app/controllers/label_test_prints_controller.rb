class LabelTestPrintsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_ability
  before_action :load_label_definitions, only: [:index]
  before_action :load_prawn_label_types, only: [:print]

  def index; end

  # Prints a sample sheet for the chosen label type, with gridlines always shown.
  # Each cell shows a calibration fact about the label type (name, description,
  # margins, gutters); once test_print_info_fields is exhausted, remaining
  # cells are left blank rather than repeating.
  def print
    label_type = params[:label_type]
    label_definition = Prawn::Labels.types[label_type]
    if label_definition.blank?
      redirect_to label_test_prints_path, alert: "Please choose a valid label type."
      return
    end

    label_record = SystemLabelType.find_by(name: label_type) || CustomLabelType.find_by(name: label_type)
    info_fields = label_record.test_print_info_fields
    count = label_definition["columns"] * label_definition["rows"]
    names = (0...count).map do |i|
      header, value = info_fields[i]
      header ? "<b>#{header}</b>\n#{value}" : ""
    end

    labels = Prawn::Labels.new(names, type: label_type, shrink_to_fit: true) do |pdf, name|
      set_font(pdf)
      pdf.text name, align: :center, inline_format: true, valign: :center, fallback_fonts: ["IPA"]
    end

    labels.document.go_to_page(1)
    labels.document.grid.show_all

    result = labels.document.render
    send_data result, filename: "label-test-print-#{Time.current}.pdf", type: "application/pdf"
  end

  # Prints a blank page containing only a measurement ruler (no label content
  # or gridlines), so it doesn't visually collide with the label test print.
  def ruler
    paper_size = LabelRuler::PAPER_SIZES.include?(params[:paper_size]) ? params[:paper_size] : "LETTER"

    pdf = Prawn::Document.new(page_size: paper_size)
    LabelRuler.draw!(pdf)

    send_data pdf.render, filename: "label-ruler-#{Time.current}.pdf", type: "application/pdf"
  end

  private

  def authenticate_ability
    authorize current_user, :manage_awards?
  end

  def load_label_definitions
    @built_in_labels = SystemLabelType.all.map { |t| { name: t.name, description: t.description } }
    @custom_label_types = CustomLabelType.all.map { |t| { name: t.name, description: t.description } }
  end

  def load_prawn_label_types
    LabelTypeRegistry.load_into_prawn!
  end
end
