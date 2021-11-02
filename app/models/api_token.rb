class ApiToken < ApplicationRecord
  validates :description, presence: true
  validates :token, presence: true

  before_validation :set_api_token

  private

  def set_api_token
    self.token ||= generate_token
  end

  def generate_token
    SecureRandom.alphanumeric(20)
  end
end
