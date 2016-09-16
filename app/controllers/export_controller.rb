class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_action
  include ExcelOutputter

  def index
  end

  def download_competitors_for_timers
    csv_string = CSV.generate do |csv|
      csv << ['bib_number', 'last_name', 'first_name', 'country']
      Registrant.active.competitor.each do |registrant|
        csv << [registrant.bib_number,
                ActiveSupport::Inflector.transliterate(registrant.last_name),
                ActiveSupport::Inflector.transliterate(registrant.first_name),
                registrant.country]
      end
    end
    filename = @config.short_name.downcase.gsub(/[^0-9a-z]/, "_") + "_registrants.csv"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  def download_events
    event_categories = Event.includes(event_categories: [:event, :translations]).flat_map{ |ev| ev.event_categories }
    event_categories_titles = event_categories.map{|ec| ec.to_s}

    event_choices = Event.includes(event_choices: [:event, :translations]).flat_map{ |ev| ev.event_choices }
    event_titles = event_choices.map{|ec| ec.to_s}

    titles = ["ID", "First Name", "Last Name", "Birthday", "Age", "Gender", "Club"] + event_categories_titles + event_titles
    competitor_data = []
    Registrant.active.includes(contact_detail: [], registrant_event_sign_ups: [], registrant_choices: :event_choice).each do |reg|
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
      competitor_data << ([reg.bib_number, reg.first_name, reg.last_name, reg.birthday, reg.age, reg.gender, reg.club] + reg_sign_up_data + reg_event_data)
    end
    @headers = titles
    @data = competitor_data
    output_spreadsheet(@headers, @data, "download_events#{Date.today}")
  end

  def download_payment_details
    ei = ExpenseItem.find(params[:data][:expense_item_id])

    headers = []
    headers << "Expense Item"
    headers << "Details: #{ei.details_label}"
    headers << "ID"
    headers << "First Name"
    headers << "Last Name"
    headers << "Age"
    headers << "City"
    headers << "State"
    headers << "Country of Residence"
    headers << "Country Representing"
    headers << "Email"
    headers << "Club"

    data = []
    ei.payment_details.includes(:payment).each do |payment_detail|
      next unless payment_detail.payment.completed
      reg = payment_detail.registrant
      data << [
        payment_detail.expense_item.to_s,
        payment_detail.details,
        reg.bib_number,
        reg.first_name,
        reg.last_name,
        reg.age,
        reg.contact_detail.city,
        reg.contact_detail.state,
        reg.contact_detail.country_residence,
        reg.contact_detail.country_representing,
        reg.contact_detail.email,
        reg.club
      ]
    end

    output_spreadsheet(headers, data, ei.name)
  end

  def results
    headers = ["ID", "Name", "Gender", "Age", "Competition", "Place", "Result Type", "Result", "Details", "Age Group"]

    data = []
    Result.includes(
      competitor: [competition: [],
                   members: [
                     registrant: [:competition_wheel_sizes]],
                   external_result: [],
                   time_results: [],
                   distance_attempts: [],
                   scores: []]).all.find_each(batch_size: 100) do |result|
      data << [
        result.competitor.bib_number,
        result.competitor.to_s,
        result.competitor.gender,
        result.competitor.age,
        result.competitor.competition.award_title,
        result.to_s,
        result.result_type,
        result.competitor.result,
        result.competitor.details,
        result.competitor.age_group_entry_description
      ]
    end
    @data = data

    output_spreadsheet(headers, data, "results")
  end

  private

  def authorize_action
    authorize :export
  end
end
