module Location
  extend ActiveSupport::Concern

  included do
    field :location, type: Hash
    index location: '2dsphere'
  end

  def distance
    self[:geo_near_distance].to_i
  end

  def neighbors
    self.class
      .not.where(id: self.id)
      .within_sphere(center: self.location, radius: 500 * 1000)
  end

  module ClassMethods
    def within_sphere(center:, radius:)
      geo_near(center).max_distance(radius).spherical
    end
  end
end
