module Location
  extend ActiveSupport::Concern

  included do
    field :location, type: Hash
    index location: '2dsphere'
  end

  def distance
    self[:geo_near_distance].to_i
  end
end
