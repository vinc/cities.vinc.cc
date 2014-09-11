class City
  include Mongoid::Document
  include Mongoid::Slug
  include Location

  field :name, type: String
  field :country, type: String
  field :elevation, type: Integer
  field :population, type: Integer
  field :is_largest, type: Boolean
  field :precipitations, type: Array
  field :min_temperatures, type: Array
  field :max_temperatures, type: Array
  field :mean_temperatures, type: Array

  has_and_belongs_to_many :mountains
  has_and_belongs_to_many :seaports

  slug :title

  def title
    [name, country].join(', ')
  end

  def find_largest(distance: 50)
    City
      .where(:population.gt => self.population)
      .geo_near(self.location)
      .max_distance(distance * 1000)
      .spherical
  end

  def build_largest
    self.is_largest = find_largest(distance: 50).count == 0
  end

  def find_mountains(max_distance: 500, min_elevation: 2500)
    return [] if self.mountains.count == 0 # FIXME MongoDB 2.4
    self.mountains
      .where(:elevation.gt => min_elevation)
      .geo_near(self.location)
      .max_distance(max_distance * 1000)
      .spherical
  end

  def find_seaports(max_distance: 20)
    return [] if self.seaports.count == 0 # FIXME MongoDB 2.4
    self.seaports
      .geo_near(self.location)
      .max_distance(max_distance * 1000)
      .spherical
  end

  def build_mountains
    self.mountains = Mountain
      .geo_near(self.location)
      .max_distance(1000 * 1000)
      .spherical.to_a
  end

  def build_seaports
    self.seaports = Seaport
      .geo_near(self.location)
      .max_distance(50 * 1000)
      .spherical.to_a
  end
end
