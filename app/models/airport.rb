class Airport
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :iata, type: String
  field :type, type: String

  slug :title

  def title
    self.name
  end
end
