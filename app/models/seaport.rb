class Seaport
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String

  slug :title

  def title
    self.name
  end
end
