class RegistrantGroup < ActiveRecord::Base
  attr_accessible :name, :registrant_id, :registrant_group_members_attributes

  belongs_to :contact_person, :class_name => "Registrant", :foreign_key => "registrant_id"

  has_many :registrant_group_members, :dependent => :destroy, :inverse_of => :registrant_group
  accepts_nested_attributes_for :registrant_group_members, :allow_destroy => true

  def to_s
    name
  end
end
