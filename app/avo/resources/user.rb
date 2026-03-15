class Avo::Resources::User < Avo::BaseResource
  self.model_class = ::User
  self.title = :email
  self.includes = []
  self.search = {
    query: -> { query.where("email ILIKE :q OR name ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :name, as: :text
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
