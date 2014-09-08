class Mountain
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :elevation, type: Integer

  has_and_belongs_to_many :cities

  slug :name
end
