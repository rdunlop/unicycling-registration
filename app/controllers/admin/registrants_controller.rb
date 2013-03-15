class Admin::RegistrantsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:undelete]
  skip_authorization_check :only => [:undelete]

  def index
    @registrants = Registrant.full_list
  end

  def undelete
    @registrant = Registrant.full_list.find(params[:id])
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to admin_registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.full_list
        format.html { render action: "index" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  def club
    @registrants = Registrant.all

    #this is supposed to list all registrants of a particular club. It's not working...
    @club_registrants = [ ]
    @registrants.each do |reg|
      if reg.club == current_user.club
        @club_registrants << reg
      end
    end
  end

  def bag_labels
    @registrants = Registrant.all

    names = []
    @registrants.each do |reg|
      names << "<b>##{reg.id}</b> #{reg.name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end
end
