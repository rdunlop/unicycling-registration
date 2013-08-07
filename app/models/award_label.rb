class AwardLabel < ActiveRecord::Base
  attr_accessible :age_group, :bib_number, :competition_name, :details, :first_name, :gender, :last_name, :partner_first_name, :partner_last_name, :place, :registrant_id, :team_name, :user_id

  validates :registrant_id, :presence => true
  validates :user_id, :presence => true
  validates :place, :presence => true, :numericality => {:greater_than => 0} 

  belongs_to :user
  belongs_to :registrant

end
