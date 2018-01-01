# == Schema Information
#
# Table name: lodging_room_options
#
#  id                   :integer          not null, primary key
#  lodging_room_type_id :integer          not null
#  position             :integer
#  name                 :string           not null
#  price_cents          :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_lodging_room_options_on_lodging_room_type_id  (lodging_room_type_id)
#

class LodgingRoomOption < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: [:lodging_room_type_id] }

  belongs_to :lodging_room_type, inverse_of: :lodging_room_options
  has_many :lodging_days, dependent: :destroy
  has_many :lodging_packages, dependent: :restrict_with_exception

  acts_as_restful_list scope: :lodging_room_type
  accepts_nested_attributes_for :lodging_days, allow_destroy: true

  scope :ordered, -> { order(:position) }

  monetize :price_cents

  def to_s
    name
  end

  # for SimpleForm element on new_lodging
  def to_label
    "#{lodging_room_type} - #{self}"
  end

  def num_selected_items(lodging_day)
    num_unpaid(lodging_day, include_incomplete_registrants: true) + num_paid(lodging_day)
  end

  def num_paid(lodging_day)
    paid_items(lodging_day).count
  end

  def num_unpaid(lodging_day, include_incomplete_registrants: false)
    unpaid_items(lodging_day, include_incomplete_registrants: include_incomplete_registrants).count
  end

  # how much have we received for the paid items
  def total_amount_paid(lodging_day)
    Money.new(paid_items(lodging_day).map(&:cost).inject(:+))
  end

  def num_pending(lodging_day)
    pending_items(lodging_day).count
  end

  def paid_items(lodging_day)
    PaymentDetail.paid.where(refunded: false).where(line_item: lodging_packages_for_day(lodging_day))
  end

  def refunded_items(lodging_day)
    PaymentDetail.paid.where(refunded: true).where(line_item: lodging_packages_for_day(lodging_day))
  end

  def pending_items(lodging_day)
    PaymentDetail.offline_pending.where(line_item: lodging_packages_for_day(lodging_day))
  end

  # Items which are unpaid.
  # Note: Free items which are associated with Paid Registrants are considered Paid/Free.
  def unpaid_items(lodging_day, include_incomplete_registrants: false)
    registrant_expense_items = RegistrantExpenseItem.where(line_item: lodging_packages_for_day(lodging_day))
    reis = if include_incomplete_registrants
             registrant_expense_items.includes(:registrant).joins(:registrant).merge(Registrant.active_or_incomplete)
           else
             registrant_expense_items.includes(:registrant).joins(:registrant).merge(Registrant.active)
           end
    reis.free.reject{ |rei| rei.registrant.reg_paid? } + reis.where(free: false)
  end

  def lodging_packages_for_day(lodging_day)
    lodging_packages.joins(lodging_package_days: :lodging_day).merge(LodgingDay.where(id: lodging_day.id))
  end
end
