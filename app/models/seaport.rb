class Seaport
  include Mongoid::Document
  include Location

  field :name, type: String
  field :country, type: String
end
