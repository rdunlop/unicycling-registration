class Avo::Resources::ContactDetail < Avo::BaseResource
  self.model_class = ::ContactDetail
  self.title = :email
  self.includes = []
  self.search = {
    query: -> { query.where("email ILIKE :q OR club ILIKE :q OR emergency_name ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :club, as: :text
    field :country_representing, as: :text
    field :emergency_name, as: :text
    field :created_at, as: :date_time
  end
end
