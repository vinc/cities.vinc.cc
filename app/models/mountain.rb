class Mountain
  include Mongoid::Document

  field :name, type: String
  field :elevation, type: Integer
  field :location, type: Hash

  index location: '2dsphere'
end
