class Admin::ExportController < Admin::BaseController
  before_filter :authenticate_user!
  skip_authorization_check # XXX because I'm using the BaseController for auth
  before_filter :super_user_check

  def super_user_check
    redirect_to root_url unless current_user.super_admin?
  end

  def index
  end

  def download
    # user has no password-stuff
    objects = {
      "event_configurations" => EventConfiguration.all,
      "categories" => Category.all,
      "events" => Event.all,
      "event_choices" => EventChoice.all,
      "expense_groups" => ExpenseGroup.all,
      "expense_items" => ExpenseItem.all,

      "users" => User.all,
      "registration_periods" => RegistrationPeriod.all,
      "registrants" => Registrant.all,
      "registrant_choices" => RegistrantChoice.all,
      "registrant_expense_items" => RegistrantExpenseItem.all,
      "payments" => Payment.all,
      "payment_details" => PaymentDetail.all
    }
    respond_to do |format|
      format.json { render :json => objects }
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

    # delete all data
    EventConfiguration.all.map{ |e| e.delete }
    Category.all.map{ |e| e.delete }
    Event.all.map{ |e| e.delete }
    EventChoice.all.map{ |e| e.delete }
    ExpenseGroup.all.map{ |e| e.delete }
    ExpenseItem.all.map{ |e| e.delete }
    RegistrationPeriod.all.map{ |e| e.delete }

    # skip deleting users
    Registrant.all.map{ |e| e.delete }
    Payment.all.map{ |e| e.delete }
    PaymentDetail.all.map{ |e| e.delete }
    RegistrantChoice.all.map{ |e| e.delete }
    RegistrantExpenseItem.all.map{ |e| e.delete }

    json['event_configurations'].each do |ec|
      create_if_needed(ec, EventConfiguration, ["logo_filename","logo_type"])
    end
    json['categories'].each do |cat|
      create_if_needed(cat, Category)
    end
    json['events'].each do |event|
      create_if_needed(event, Event, [], [:build_associated_event_choice])
    end
    json['event_choices'].each do |ec|
      create_if_needed(ec, EventChoice)
    end
    json['expense_groups'].each do |eg|
      create_if_needed(eg, ExpenseGroup)
    end
    json['expense_items'].each do |ei|
      create_if_needed(ei, ExpenseItem)
    end
    json['registration_periods'].each do |rp|
      create_if_needed(rp, RegistrationPeriod)
    end

    json['users'].each do |user|
      create_if_needed(user, User, ["admin", "super_admin"])
    end
    json['registrants'].each do |reg|
      create_if_needed(reg, Registrant)
    end
    json['payments'].each do |payment|
      create_if_needed(payment, Payment)
    end
    json['payment_details'].each do |pd|
      create_if_needed(pd, PaymentDetail)
    end
    json['registrant_choices'].each do |rc|
      create_if_needed(rc, RegistrantChoice)
    end
    json['registrant_expense_items'].each do |rei|
      create_if_needed(rei, RegistrantExpenseItem)
    end

    respond_to do |format|
      format.html { redirect_to admin_events_path }
    end
  end
end
