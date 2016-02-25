class SampleData::RegistrantsController < SampleData::BaseController
  # GET /sample_data/registrants
  def index
  end

  # Create a number of fake registrants
  # POST /sample_data/registrants
  def create
    # Notes:
    # All are eligible
    # All are in the User.first user.
    # All have 24" wheel?
    num_registrants = params[:number].to_i
    resu_errors = 0
    num_registrants.times do
      registrant = Registrant.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        birthday: Faker::Date.between(5.years.ago, 55.years.ago),
        gender: ["Male", "Female"].sample,
        registrant_type: "competitor",
        ineligible: false,
        rules_accepted: true,
        online_waiver_acceptance: true,
        user: User.first
      )
      ContactDetail.create!(
        registrant: registrant,
        address: Faker::Address.street_name,
        city: Faker::Address.city,
        state_code: Faker::Address.state_abbr,
        zip: Faker::Address.postcode,
        country_residence: Faker::Address.country_code,
        country_representing: Faker::Address.country_code,
        phone: Faker::PhoneNumber.phone_number,
        email: Faker::Internet.email,
        emergency_name: Faker::Name.name,
        emergency_relationship: ["Father", "Mother", "Spouse"].sample,
        emergency_primary_phone: Faker::PhoneNumber.phone_number,
        responsible_adult_name: Faker::Name.name,
        responsible_adult_phone: Faker::PhoneNumber.phone_number
      )
      if params[:sign_up_for_all_events] == "1"
        Event.all.each do |event|
          resu = RegistrantEventSignUp.new(
            registrant: registrant,
            signed_up: true,
            event_category: event.event_categories.first,
            event: event
          )
          unless resu.save
            resu_errors += 1
          end
        end
      end
    end
    flash[:notice] = "#{num_registrants} Sample Registrants Created (#{resu_errors} event sign up errors)"
    redirect_to sample_data_registrants_path
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:alert] = "Error creating record: #{invalid}"
    redirect_to sample_data_registrants_path
  end
end
