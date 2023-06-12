class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_action
  include ExcelOutputter
  include CsvOutputter

  def index; end

  def download_registrants
    exporter = Exporters::RegistrantExporter.new
    headers = exporter.headers
    data = exporter.rows
    output_csv(headers, data, "download_registrants_#{Date.current}.csv")
  end

  def download_competitors_for_timers
    exporter = Exporters::AllCompetitors.new
    filename = "#{@config.short_name.downcase.gsub(/[^0-9a-z]/, '_')}_registrants.csv"
    output_csv(exporter.headers, exporter.rows, filename)
  end

  def download_events
    exporter = Exporters::EventsExporter.new
    headers = exporter.headers
    data = exporter.rows
    output_spreadsheet(headers, data, "download_events_#{Date.current}")
  end

  def download_payment_details
    ei = ExpenseItem.find(params[:data][:expense_item_id])
    exporter = Exporters::PaymentDetailsExporter.new(ei)
    headers = exporter.headers
    data = exporter.rows

    output_spreadsheet(headers, data, ei.name)
  end

  def download_payment_details_by_category
    expense_group = ExpenseGroup.find(params[:data][:expense_group_id])

    data = []
    headers = nil
    expense_group.expense_items.each do |ei|
      exporter = Exporters::PaymentDetailsExporter.new(ei)
      headers = exporter.headers
      data += exporter.rows
    end

    output_spreadsheet(headers, data, expense_group.group_name)
  end

  def results
    exporter = Exporters::ResultsExporter.new
    headers = exporter.headers
    data = exporter.rows
    output_spreadsheet(headers, data, "results")
  end

  private

  def authorize_action
    authorize :export
  end
end
