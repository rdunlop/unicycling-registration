class ImportedRegistrant < ApplicationRecord
  validates :first_name, :last_name, presence: true
  validates :bib_number, presence: true, uniqueness: true

  has_many :members, as: :registrant, dependent: :destroy
  has_many :competitors, through: :members

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

  private

  def set_sorted_last_name
    self.sorted_last_name = ActiveSupport::Inflector.transliterate(last_name).downcase if last_name
  end
end
