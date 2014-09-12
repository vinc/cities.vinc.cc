class Seaport
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :country, type: Country

  slug :title

  def title
    [name, country].join(', ')
  end
end
