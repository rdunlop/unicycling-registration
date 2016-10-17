class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_action
  include ExcelOutputter

  def index
  end

  def download_competitors_for_timers
    exporter = CompetitorsExporter.new
    csv_string = CSV.generate do |csv|
      csv << exporter.headers
      exporter.rows.each do |row|
        csv << row
      end
    end
    filename = @config.short_name.downcase.gsub(/[^0-9a-z]/, "_") + "_registrants.csv"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  def download_events
    exporter = EventsExporter.new
    headers = exporter.headers
    data = exporter.rows
    output_spreadsheet(headers, data, "download_events#{Date.today}")
  end

  def download_payment_details
    ei = ExpenseItem.find(params[:data][:expense_item_id])
    exporter = PaymentDetailsExporter.new(ei)
    headers = exporter.headers
    data = exporter.rows

    output_spreadsheet(headers, data, ei.name)
  end

  def results
    exporter = ResultsExporter.new
    headers = exporter.headers
    data = exporter.rows
    output_spreadsheet(headers, data, "results")
  end

  private

  def authorize_action
    authorize :export
  end
end
