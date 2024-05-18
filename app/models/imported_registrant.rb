class ImportedRegistrant < ApplicationRecord
  validates :first_name, :last_name, presence: true
  validates :bib_number, presence: true, uniqueness: true

  before_validation :set_sorted_last_name

  def set_sorted_last_name
    self.sorted_last_name = ActiveSupport::Inflector.transliterate(last_name).downcase if last_name
  end
end
