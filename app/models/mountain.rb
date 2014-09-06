class Mountain
  include Mongoid::Document
  include Location

  field :name, type: String
  field :elevation, type: Integer
end
