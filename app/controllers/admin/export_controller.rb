class Admin::ExportController < Admin::BaseController
  before_filter :authenticate_user!
  authorize_resource :class => false

  def index
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
