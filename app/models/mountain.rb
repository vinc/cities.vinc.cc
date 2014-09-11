class Mountain
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :elevation, type: Integer

  slug :name
end
