class Registrant < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :birthday, :city, :country, :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :zip_code

  validates :birthday, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :city, :presence => true
  validates :country, :presence => true
  validates :gender, :presence => true

  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}


  has_many :registrant_choices


  def chose(event_choice)
    choices = registrant_choices.where({:event_choice_id => event_choice.id})
    if choices.count > 0
      if choices.first.value == "1"
        true
      else
        false
      end
    else
      false
    end
  end
end
