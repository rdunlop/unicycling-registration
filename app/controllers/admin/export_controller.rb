require 'csv'
class Admin::ExportController < Admin::BaseController
  before_filter :authenticate_user!
  authorize_resource :class => false

  def index
  end

  def download_event_configuration
    obj = {}
    obj["age_group_types"] = AgeGroupType.all
    respond_to do |format|
      format.json { render :json => obj }
    end
  end

  # POST /admin/export/upload_event_configuration
  # Receives JSON data in the 'data' field
  def upload_event_configuration
    json = JSON.parse(params[:convert][:data])

    created_records = 0
    json["age_group_types"].each do |agt|
      age_group_type_model = AgeGroupType.find_by_name(agt["name"])
      if age_group_type_model.nil?
        values = agt
        values = values.clone
        values.delete("age_group_entries")
        age_group_type_model = AgeGroupType.create(values)
        created_records += 1
      end
      entries = agt["age_group_entries"]
      entries.each do |age|
        age_group_entry_model = age_group_type_model.age_group_entries.find_by_short_description(age["short_description"])
        if age_group_entry_model.nil?
          wheel_size_name = age["wheel_size_name"]
          age.delete("wheel_size_name")
          unless wheel_size_name.nil?
            wheel_size = WheelSize.find_or_create_by_description(wheel_size_name)
            if wheel_size.new_record?
              wheel_size.position = 1
              wheel_size.save!
            end
          end
          age_group_entry_model = age_group_type_model.age_group_entries.build(age)
          age_group_entry_model.wheel_size = wheel_size
          age_group_entry_model.save!
          created_records += 1
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path, :notice => "Created #{created_records} records" }
    end
  end

  def download_registrants
    obj = {}
    obj["registrants"] = Registrant.all
    respond_to do |format|
      format.json { render :json => obj }
    end
  end

  # POST /admin/export/upload_registrants
  # Receives JSON data in the 'data' field
  def upload_registrants
    json = JSON.parse(params[:convert][:data])

    created_records = 0
    json["registrants"].each do |reg|
      registrant_model = Registrant.find_by_bib_number(reg["bib_number"])
      if registrant_model.nil?
        # determine if we need to create a user object
        user_model = User.find_by_email(reg["user_email"])
        if user_model.nil?
          user_model = User.new({:email => reg["user_email"]})
          user_model.save(:validate => false)
        end
        values = reg
        values = values.clone
        values.delete("user_email")
        bib_number = values["bib_number"]
        values.delete("bib_number")
        registrant_model = Registrant.new(values)
        registrant_model.user = user_model
        registrant_model.bib_number = bib_number
        registrant_model.save(:validate => false)
        created_records += 1
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path, :notice => "Created #{created_records} records" }
    end
  end

  def download_time_results
    obj = {}
    event_category = EventCategory.find(params[:event_category_id])
    obj["time_results"] = event_category.time_results
    respond_to do |format|
      format.json { render :json => obj }
    end
  end

  # POST /admin/export/upload_time_results
  # Receives JSON data in the 'data' field
  def upload_time_results
    json = JSON.parse(params[:convert][:data])
    event_category = EventCategory.find(params[:convert][:event_category_id])

    created_records = 0
    json["time_results"].each do |tr|
      reg = Registrant.find_by_bib_number(tr["bib_number"])
      new_tr = TimeResult.new({:registrant_id => reg.id,
                              :minutes => tr["minutes"],
                              :seconds => tr["seconds"],
                              :thousands => tr["thousands"],
                              :event_category_id => event_category.id,
                              :disqualified => tr["disqualified"]})
      new_tr.save
      created_records += 1
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path, :notice => "Created #{created_records} records" }
    end
  end


  def configuration_data
    # Class                 Delete  SkipValues   SkipCallbacks
    [ [EventConfiguration,  true,   [], []],
      [Category,            true,   [], []],
      [Event,               true,   [], [:build_associated_event_choice]],
      [EventChoice,         true,   [], []],
      [ExpenseGroup,        true,   [], []],
      [ExpenseItem,         true,   [], []],
      [RegistrationPeriod,  true,   [], []]
    ]
  end

  def user_data
    [ [User,                false,  ["admin", "super_admin"], []],
      [Registrant,          true,   [], []],
      [RegistrantChoice,    true,   [], []],
      [RegistrantExpenseItem, true, [], []],
      [Payment,             true,   [], []],
      [PaymentDetail,       true,   [], []]
    ]
  end
  def download_configuration
    obj = {}
    configuration_data.each do |cf|
      obj[cf[0].name] = cf[0].all
    end

    respond_to do |format|
      format.json { render :json => obj }
    end
  end
  def download_data
    obj = {}
    user_data.each do |cf|
      obj[cf[0].name] = cf[0].all
    end

    respond_to do |format|
      format.json { render :json => obj }
    end
  end

  def create_if_needed(obj, model, also_delete = [], skip_callback = [])  
    return if model.exists?(obj['id'])
    #get the original object attributes  
    old_id = obj['id']

    # remove any that will cause problems  
    obj.delete("id")  
    obj.delete("created_at")  
    obj.delete("updated_at")  
    also_delete.each do |e|
      obj.delete(e)
    end

    # create the new object  
    new_o = model.new   

    # use send yo bypass mass assignment issues  
    new_o.send :attributes=, obj

    # set the id separately  
    new_o.id =old_id

    puts "creating #{model} #{old_id}"
    skip_callback.each do |cb|
      model.skip_callback(:create, :before, cb)
    end

    # make sure to save without validations  
    new_o.save(:validate => false)

    skip_callback.each do |cb|
      model.set_callback(:create, :before, cb)
    end
  end

  # POST /admin/events/upload
  def upload
    if params[:convert][:events_file].respond_to?(:tempfile)
      upload_file = params[:convert][:events_file].tempfile
    else
      upload_file = params[:convert][:events_file]
    end

    json = JSON.parse(upload_file.read)

    (configuration_data + user_data).each do |cf|
      if json[cf[0].name]
        puts "found #{cf[0].name} data"
        if cf[1]
          puts "deleting #{cf[0].name} data"
          cf[0].all.map{ |e| e.delete }
        end
        json[cf[0].name].each do |json_entry|
          create_if_needed(json_entry, cf[0], cf[2], cf[3])
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path }
    end
  end

  def download_events

    event_categories = Event.includes(:event_categories => :event).all.flat_map{ |ev| ev.event_categories }
    event_categories_titles = event_categories.map{|ec| ec.to_s}

    event_choices = Event.includes(:event_choices => :event).all.flat_map{ |ev| ev.event_choices }
    event_titles = event_choices.map{|ec| ec.to_s}

    titles = ["Registrant Name", "Age", "Gender"] + event_categories_titles + event_titles
    competitor_data = []
    Registrant.includes(:registrant_event_sign_ups => {}, :registrant_choices => :event_choice).all.each do |reg|
      comp_base = [reg.name, reg.age, reg.gender]
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
        #rc = reg.registrant_event_sign_ups.where({:event_category_id => ec.id}).first
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
        #rc = reg.registrant_choices.where({:event_choice_id => ec.id}).first
        if rc.nil?
          reg_event_data += [nil]
        else
          reg_event_data += [rc.describe_value]
        end
      end
      competitor_data << ([reg.name, reg.age, reg.gender] + reg_sign_up_data + reg_event_data)
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

  # defines the SQL file necessary to run in order to sync UCP with the UDA
  # Includes Registrants, and their events.
  # NOTE: requires that UCP be configured properly in the tOnlineMatch_tbl
  def download_ucp_sql
    all_strings = ""
    all_strings = "DELETE from tUtlOnlineRegistrations_tbl;\n"
    Registrant.all.each do |reg|
      fields = []
      fields << ["recordid", reg.bib_number]
      fields << ["userid", reg.user_id]
      fields << ["fname", reg.first_name]
      fields << ["mname", reg.middle_initial]
      fields << ["lname", reg.last_name]
      fields << ["birthmonth", reg.birthday.month]
      fields << ["birthday", reg.birthday.day]
      fields << ["birthyear", reg.birthday.year]
      fields << ["gender" , reg.gender]
      fields << ["address1", reg.address]
      fields << ["city", reg.city]
      fields << ["state", reg.state]
      fields << ["zipcode", reg.zip]
      fields << ["country", reg.country]
      fields << ["phone", reg.phone]
      fields << ["mobile", reg.mobile]
      fields << ["email", reg.email]
      fields << ["club", reg.club]
      fields << ["clubcontact", reg.club_contact]
      fields << ["usamembernumber", reg.usa_member_number]
      fields << ["emergencyname", reg.emergency_name]
      fields << ["emergencyrelationship", reg.emergency_relationship]
      fields << ["emergencyatconvention", reg.emergency_attending]
      fields << ["emergencyPhone", reg.emergency_primary_phone]
      fields << ["emergencyOtherPhone", reg.emergency_other_phone]
      fields << ["parentname", reg.responsible_adult_name]
      fields << ["parentphone" ,reg.responsible_adult_phone]

      # Event Sign up fields
      reg.registrant_event_sign_ups.each do |sign_up|
        next unless sign_up.signed_up?
        fields << [sign_up.event.export_name, sign_up.event_category.name]
      end

      #Event Choice fields
      reg.registrant_choices.each do |reg_choice|
        next unless reg_choice.has_value?
        fields << [reg_choice.event_choice.export_name, reg_choice.value]
      end

      result_string = "INSERT into tUtlOnlineRegistrations_tbl ("
      value_string = ") VALUES ("

      fields.each do |field, value|
        result_string += "#{field},"
        value_string += value.inspect + "," #"\"#{value}\","
      end
      # last field needs to be something without a trailing ','
      result_string += "fee"
      value_string += reg.competitor? ? "2": "1"

      final_string = result_string + value_string + ");\n"

      all_strings += final_string
    end
    filename = "registrant_export.txt"
    send_data(all_strings,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
  end
end
