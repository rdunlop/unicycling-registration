class Avo::Resources::Registrant < Avo::BaseResource
  self.model_class = ::Registrant
  self.title = :full_name
  self.includes = []
  self.find_record_method = -> { query.find_by!(bib_number: id) }
  self.search = {
    query: -> { query.where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :first_name, as: :text
    field :last_name, as: :text
    field :deleted, as: :boolean
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
