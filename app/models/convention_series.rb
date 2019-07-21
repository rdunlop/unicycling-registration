# == Schema Information
#
# Table name: public.convention_series
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_convention_series_on_name  (name) UNIQUE
#

class ConventionSeries < ApplicationRecord
  has_many :convention_series_members, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end

  def add(tenant_name)
    convention_series_members.create(tenant: find_tenant(tenant_name))
  end

  def remove(tenant_name)
    convention_series_members.find_by(tenant: find_tenant(tenant_name)).destroy
  end

  def subdomains
    convention_series_members.includes(:tenant).pluck(Tenant.arel_table[:subdomain])
  end

  # Return a hash of registrant data across all members
  def registrant_data
    data = {}
    subdomains.each do |subdomain|
      Apartment::Tenant.switch(subdomain) do
        subdomain_data = Registrant.all.select(:bib_number, :first_name, :last_name).map do |reg|
          {
            bib_number: reg.bib_number,
            name: reg.full_name
          }
        end
        data[subdomain] = subdomain_data
      end
    end
    # data = {
    #   "tenant1" => [
    #      { bib_number: 1, name: "Bob Smith" },
    #      { bib_number: 2, name: "Jane Smith" }
    #   ],
    #   "tenant2" => [
    #      { bib_number: 1, name: "Bob Smith" },
    #      { bib_number: 2, name: "Jane Smith" }
    #      { bib_number: 3, name: "Mary Smith" }
    #   ],
    # }

    ids = data.map do |_subdomain_name, subdomain_data|
      subdomain_data.map { |entry| entry[:bib_number] }
    end.flatten.uniq.sort

    sub_data = subdomains.each_with_object({}) do |subdomain, subdomain_hash|
      regs = data[subdomain].each_with_object({}) do |registrant, collected_hash|
        collected_hash[registrant[:bib_number]] = registrant[:name]
      end
      subdomain_hash[subdomain] = regs
    end

    {
      ids: ids,
      subdomains: sub_data
    }
    # ids: [1, 2, 3]
    # subdomains: {
    #  "tenant1" => {
    #    1 => "Bob Smith",
    #    2 => "Jane Smith",
    #   },
    #   "tenant2" => {
    #    1 => "Bob Smith",
    #    2 => "Jane Smith",
    #    3 => "Mary Smith",
    #   }
    # }
  end

  private

  def find_tenant(tenant_name)
    Tenant.find_by(subdomain: tenant_name)
  end
end
