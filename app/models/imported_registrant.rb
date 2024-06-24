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
