# == Schema Information
#
# Table name: registrant_choices
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  event_choice_id :integer
#  value           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class RegistrantChoice < ActiveRecord::Base
  mount_uploader :music, MusicUploader

  validates :event_choice_id, :presence => true, :uniqueness => {:scope => [:registrant_id]}
  validates :registrant, :presence => true

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :event_choice
  belongs_to :registrant, :inverse_of => :registrant_choices

  validates_format_of :value, :with => /\A([0-9]{1,2}:)+[0-9]{2}\z/, :if => "event_choice.try(:cell_type) == 'best_time'", :message => "must be of the form hh:mm:ss or mm:ss", :allow_blank => true

  def has_value?
    case event_choice.cell_type
    when "boolean"
      return self.value != "0"
    when "multiple"
      return self.value != ""
    when "text"
      return self.value != ""
    when "best_time"
      return self.value != ""
    when "file"
      return self.music.present?
    else
      return false
    end
  end

  def describe_value
    case event_choice.cell_type
    when "boolean"
      self.value != "0" ? "yes" : "no"
    else
      self.value
    end
  end
end
