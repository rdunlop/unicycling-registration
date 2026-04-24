# == Schema Information
#
# Table name: imported_registrants
#
#  id               :bigint           not null, primary key
#  first_name       :string           not null
#  last_name        :string           not null
#  birthday         :date
#  gender           :string
#  deleted          :boolean          default(FALSE), not null
#  bib_number       :integer          not null
#  age              :integer
#  club             :string
#  ineligible       :boolean          default(FALSE), not null
#  sorted_last_name :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_imported_registrants_on_bib_number  (bib_number) UNIQUE
#  index_imported_registrants_on_deleted     (deleted)
#
class ImportedRegistrant < ApplicationRecord
  include CalculatedAge

  validates :first_name, :last_name, presence: true
  validates :bib_number, presence: true, uniqueness: true

  has_many :members, as: :registrant, dependent: :destroy
  has_many :competitors, through: :members

  before_validation :set_age
  before_validation :set_sorted_last_name

  def to_s
    "#{first_name} #{last_name}"
  end

  def with_id_to_s
    "##{bib_number} - #{self}"
  end

  def external_id
    bib_number
  end

  def gender
    "Male"
  end

  def wheel_size_id
    nil
  end

  private

  def set_age
    return if birthday.blank?

    self.age = determined_age
  end

  def set_sorted_last_name
    self.sorted_last_name = ActiveSupport::Inflector.transliterate(last_name).downcase if last_name
  end
end
