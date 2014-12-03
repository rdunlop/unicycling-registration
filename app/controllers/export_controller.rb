class ExportController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :class => false

  def index
  end

  def download_competitors_for_timers
    csv_string = CSV.generate do |csv|
      csv << ['bib_number', 'last_name', 'first_name', 'country']
      Registrant.active.where(competitor: true).each do |registrant|
        csv << [registrant.bib_number,
                ActiveSupport::Inflector.transliterate(registrant.last_name),
                ActiveSupport::Inflector.transliterate(registrant.first_name),
                registrant.country]
      end
    end
    filename = @config.short_name.downcase.gsub(/[^0-9a-z]/, "_") + "_registrants.csv"
    send_data(csv_string,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
  end

  def download_events
    event_categories = Event.includes(:event_categories => :event).flat_map{ |ev| ev.event_categories }
    event_categories_titles = event_categories.map{|ec| ec.to_s}

    event_choices = Event.includes(:event_choices => :event).flat_map{ |ev| ev.event_choices }
    event_titles = event_choices.map{|ec| ec.to_s}

    titles = ["ID", "Registrant Name", "Age", "Gender"] + event_categories_titles + event_titles
    competitor_data = []
    Registrant.active.includes(:registrant_event_sign_ups => [], :registrant_choices => :event_choice).each do |reg|
      reg_sign_up_data = []
      event_categories.each do |ec|
        # for performance reasons, loop it
        rc = nil
        reg.registrant_event_sign_ups.each do |r|
          if r.event_category_id == ec.id
            rc = r
            break
          end
        end
        # rc = reg.registrant_event_sign_ups.where({:event_category_id => ec.id}).first
        if rc.nil?
          reg_sign_up_data += [nil]
        else
          reg_sign_up_data += [rc.signed_up]
        end
      end

      reg_event_data = []
      event_choices.each do |ec|
        # for performance reasons, loop it
        rc = nil
        reg.registrant_choices.each do |r|
          if r.event_choice_id == ec.id
            rc = r
            break
          end
        end
        # rc = reg.registrant_choices.where({:event_choice_id => ec.id}).first
        if rc.nil?
          reg_event_data += [nil]
        else
          reg_event_data += [rc.describe_value]
        end
      end
      competitor_data << ([reg.bib_number, reg.name, reg.age, reg.gender] + reg_sign_up_data + reg_event_data)
    end
    @data = [titles] + competitor_data

    s = Spreadsheet::Workbook.new

    sheet = s.create_worksheet
    @data.each_with_index do |row, row_number|
      row.each_with_index do |cell, column_number|
        sheet[row_number,column_number] = cell
      end
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, :filename => "download_events#{Date.today}.xls" }
    end
  end

  def download_payment_details
    ei = ExpenseItem.find(params[:data][:expense_item_id])

    s = Spreadsheet::Workbook.new
    sheet = s.create_worksheet

    row = 0
    sheet[0,0] = "Expense Item"
    sheet[0,1] = "Details: #{ei.details_label}"
    sheet[0,2] = "First Name"
    sheet[0,3] = "Last Name"
    sheet[0,4] = "Birthday"
    sheet[0,5] = "Address Line1"
    sheet[0,6] = "City"
    sheet[0,7] = "State"
    sheet[0,8] = "Zip"
    sheet[0,9] = "Country"
    sheet[0,10] = "Phone"
    sheet[0,11] = "Email"
    sheet[0,12] = "Club"
    row = 1

    ei.payment_details.includes(:payment).each do |payment_detail|
      next unless payment_detail.payment.completed
      reg = payment_detail.registrant
      sheet[row,0] = payment_detail.expense_item.to_s
      sheet[row,1] = payment_detail.details
      sheet[row,2] = reg.first_name
      sheet[row,3] = reg.last_name
      sheet[row,4] = reg.birthday
      sheet[row,5] = reg.contact_detail.address
      sheet[row,6] = reg.contact_detail.city
      sheet[row,7] = reg.contact_detail.state
      sheet[row,8] = reg.contact_detail.zip
      sheet[row,9] = reg.contact_detail.country_residence
      sheet[row,10] = reg.contact_detail.country_representing
      sheet[row,11] = reg.contact_detail.phone
      sheet[row,12] = reg.contact_detail.email
      sheet[row,13] = reg.club
      row += 1
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, :filename => "#{ei.description}.xls" }
    end
  end

  def download_all_payments
    s = Spreadsheet::Workbook.new
    sheet = s.create_worksheet

    row = 0
    sheet[0,0] = "ID"
    sheet[0,1] = "USA#"
    sheet[0,2] = "First Name"
    sheet[0,3] = "Last Name"
    sheet[0,4] = "Birthday"
    sheet[0,5] = "Address Line1"
    sheet[0,6] = "City"
    sheet[0,7] = "State"
    sheet[0,8] = "Zip"
    sheet[0,9] = "Country"
    sheet[0,10] = "Phone"
    sheet[0,11] = "Email"
    sheet[0,12] = "Club"

    row = 1
    Registrant.active.includes(:payment_details => [:payment]).each do |reg|
      sheet[row,0] = reg.bib_number
      sheet[row,1] = reg.contact_detail.usa_member_number
      sheet[row,2] = reg.first_name
      sheet[row,3] = reg.last_name
      sheet[row,4] = reg.birthday
      sheet[row,5] = reg.contact_detail.address
      sheet[row,6] = reg.contact_detail.city
      sheet[row,7] = reg.contact_detail.state
      sheet[row,8] = reg.contact_detail.zip
      sheet[row,9] = reg.contact_detail.country_residence
      sheet[row,10] = reg.contact_detail.phone
      sheet[row,11] = reg.contact_detail.email
      sheet[row,12] = reg.club
      column = 13
      reg.paid_details.each do |pd|
        sheet[row, column] = pd.expense_item.to_s
        column += 1
        sheet[row, column] = pd.details
        column += 1
      end
      row += 1
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, :filename => "registrants_with_payments.xls" }
    end
  end

  def results
    s = Spreadsheet::Workbook.new
    sheet = s.create_worksheet

    row = 0
    headers =["ID", "Name", "Gender", "Age", "Competition", "Place", "Result Type", "Result",  "Details",  "Age Group"]

    headers.each_with_index do |head, index|
      sheet[0, index] = head
    end

    row = 1
    Result.includes(competitor: [competition: [], members: [registrant: [:competition_wheel_sizes]], external_results: [], time_results: [], distance_attempts: [], scores: []]).all.each do |result|
      sheet[row,0] = result.competitor.bib_number
      sheet[row,1] = result.competitor.to_s
      sheet[row,2] = result.competitor.gender
      sheet[row,3] = result.competitor.age
      sheet[row,4] = result.competitor.competition.award_title
      sheet[row,5] = result.to_s
      sheet[row,6] = result.result_type
      sheet[row,7] = result.competitor.result
      sheet[row,8] = result.competitor.details
      sheet[row,9] = result.competitor.age_group_entry_description
      row += 1
    end

    report = StringIO.new
    s.write report

    respond_to do |format|
      format.xls { send_data report.string, :filename => "results.xls" }
      # format.xls { render text: report.string, :filename => "results.xls" }
    end
  end
end
