class Seaport
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :country, type: String

  has_and_belongs_to_many :cities

  slug :title

  def title
    [name, country].join(', ')
  end
end
