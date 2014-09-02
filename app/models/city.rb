class City
  include Mongoid::Document

  field :name, type: String
  field :country, type: String
  field :elevation, type: Integer
  field :population, type: Integer
  field :location, type: Hash

  index location: '2dsphere'
end
