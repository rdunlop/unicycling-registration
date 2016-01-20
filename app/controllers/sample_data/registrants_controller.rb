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
    num_registrants.times do
      registrant = Registrant.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        birthday: Faker::Date.between(5.years.ago, 55.years.ago),
        gender: ["Male", "Female"].sample,
        registrant_type: "competitor",
        ineligible: false,
        user: User.first,
      )
      contact_detail = ContactDetail.create!(
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
      )
    end
    flash[:notice] = "#{num_registrants} Sample Registrants Created"
    redirect_to sample_data_registrants_path
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:alert] = "Error creating record: #{invalid}"
    redirect_to sample_data_registrants_path
  end
end
