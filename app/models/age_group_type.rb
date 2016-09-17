# == Schema Information
#
# Table name: age_group_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_age_group_types_on_name  (name) UNIQUE
#

class AgeGroupType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :age_group_entries, -> {order "age_group_entries.position"}, dependent: :destroy, inverse_of: :age_group_type
  has_many :competitions, dependent: :nullify

  accepts_nested_attributes_for :age_group_entries, allow_destroy: true

  after_save :update_competitor_age_group_entries
  after_touch :update_competitor_age_group_entries

  default_scope { order(:name) }

  # Touch all age groups so that it triggers updates
  # to all competitors age group entries
  def self.update_all
    Apartment.tenant_names.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        AgeGroupType.all.find_each do |age_group_type|
          age_group_type.touch
        end
      end
    end
  end

  def age_group_entries_by_age_gender
    age_group_entries.reorder(:gender, :start_age)
  end

  # Return the age group entry that meets the given age requirements
  def age_group_entry_for(age, gender, default_wheel_size_id = nil)
    entries = age_group_entries.where("(start_age <= :age AND :age <= end_age) AND " \
                                      "(gender = 'Mixed' OR gender = :gender) AND " \
                                      "(wheel_size_id IS NULL or wheel_size_id = :wheel_size_id)",
                                      age: age, gender: gender, wheel_size_id: default_wheel_size_id)
    entries.first
  end

  def as_json(options = {})
    options = {
      except: [:id, :updated_at, :created_at],
      methods: [:age_group_entries]
    }
    super(options)
  end

  def to_s
    name
  end

  private

  def update_competitor_age_group_entries
    competitions.includes(:competitors).each do |competition|
      competition.competitors.each do |competitor|
        competitor.update_age_group_entry
      end
    end
  end
end
