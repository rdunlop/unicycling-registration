# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  resource_id   :integer
#  resource_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  scopify

  def to_s
    res = name
    res += "(#{resource})" if resource.present?
    res
  end
end
