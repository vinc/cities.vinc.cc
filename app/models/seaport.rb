class Seaport
  include Mongoid::Document

  field :name, type: String
  field :country, type: String
  field :location, type: Hash

  index location: '2dsphere'
end
