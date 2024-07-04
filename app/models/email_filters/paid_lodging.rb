# Allows selecting the LodgingRoomOption to send emails to
class EmailFilters::PaidLodging
  attr_reader :arguments

  def initialize(arguments = nil)
    @arguments = arguments
  end

  def self.config
    EmailFilters::SelectType.new(
      filter: "lodging_room_option",
      description: "Users+Registrants who have PAID for a particular Lodging(s)",
      possible_arguments: ::LodgingRoomOption.all,
      custom_show_argument: proc { |element| [element.to_label, element.id] },
      input_type: :multi_select
    )
  end

  def detailed_description
    "Emails of users/registrants who have Paid for #{lodging_room_options.map(&:to_label).join(' ')}"
  end

  def filtered_user_emails
    users = registrants.map(&:user).uniq
    users.map(&:email).compact.uniq
  end

  def filtered_registrant_emails
    registrants.map(&:email).compact.uniq
  end

  def registrants
    @paid_packages = LodgingPackage
                     .joins(:lodging_room_type, :payment_details)
                     .includes(:lodging_room_option, :lodging_package_days)
                     .where(lodging_room_option: lodging_room_options)
                     .merge(PaymentDetail.paid.where(refunded: false))

    @paid_packages.map(&:registrant)
  end

  # object whose policy must respond to `:contact_registrants?`
  def authorization_object
    lodging_room_options
  end

  def valid?
    lodging_room_options&.any?
  end

  private

  def lodging_room_options
    return @lodging_room_options if @lodging_room_options

    @lodging_room_options = LodgingRoomOption.where(id: arguments) if arguments.present?

    @lodging_room_options
  end
end
