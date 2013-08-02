class RegistrantGroup < ActiveRecord::Base
  attr_accessible :name, :registrant_id

  belongs_to :contact_person, :class_name => "Registrant", :foreign_key => "registrant_id"

  has_many :registrant_group_members, :dependent => :destroy
end
