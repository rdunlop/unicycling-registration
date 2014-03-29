# == Schema Information
#
# Table name: registrant_groups
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  registrant_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class RegistrantGroup < ActiveRecord::Base
  belongs_to :contact_person, :class_name => "Registrant", :foreign_key => "registrant_id"

  has_many :registrant_group_members, :dependent => :destroy, :inverse_of => :registrant_group
  accepts_nested_attributes_for :registrant_group_members, :allow_destroy => true
  has_many :registrants, :through => :registrant_group_members


  def sorted_registrants
    registrants.sort{|a,b| a.address <=> b.address }
  end

  def to_s
    name
  end
end
