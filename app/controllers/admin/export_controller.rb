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

    updates = ""
    json["age_group_types"].each do |agt|
      age_group_type_model = AgeGroupType.find_by_name(agt["name"])
      if age_group_type_model.nil?
        values = agt
        values = values.clone
        values.delete("age_group_entries")
        age_group_type_model = AgeGroupType.create(values)
        updates +=  "created AgeGroupType: #{age_group_type_model}\n"
      end
      entries = agt["age_group_entries"]
      entries.each do |age|
        age_group_entry_model = age_group_type_model.age_group_entries.find_by_short_description(age["short_description"])
        if age_group_entry_model.nil?
          age_group_entry_model = age_group_type_model.age_group_entries.build(age)
          age_group_entry_model.save!
          updates += "created AgeGroupEntry: #{age_group_entry_model}\n"
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path, :notice => updates }
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

    updates = ""
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
        updates +=  "created Registrant: #{registrant_model}\n"
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_export_index_path, :notice => updates }
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
    [ [User,                false,  ["admin", "super_admin", "club_admin"], []],
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

    event_categories = Event.all.flat_map{ |ev| ev.event_categories }
    event_categories_titles = event_categories.map{|ec| ec.to_s}

    event_choices = Event.all.flat_map{ |ev| ev.event_choices }
    event_titles = event_choices.map{|ec| ec.to_s}

    titles = ["Registrant Name", "Age", "Gender"] + event_categories_titles + event_titles
    competitor_data = []
    Registrant.all.each do |reg|
      comp_base = [reg.name, reg.age, reg.gender]
      reg_sign_up_data = []
      event_categories.each do |ec|
        rc = reg.registrant_event_sign_ups.where({:event_category_id => ec.id}).first
        if rc.nil?
          reg_sign_up_data += [nil]
        else
          reg_sign_up_data += [rc.signed_up]
        end
      end

      reg_event_data = []
      event_choices.each do |ec|
        rc = reg.registrant_choices.where({:event_choice_id => ec.id}).first
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
end
