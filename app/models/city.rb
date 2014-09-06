class City
  include Mongoid::Document
  include Location

  field :name, type: String
  field :country, type: String
  field :elevation, type: Integer
  field :population, type: Integer

  def title
    [name, country].join(', ')
  end

  def biggest?(distance: 50)
    City
      .where(:population.gt => self.population)
      .geo_near(self.location)
      .max_distance(distance * 1000)
      .spherical
      .count == 0
  end

  def mountains(max_distance: 500, min_elevation: 2500)
    Mountain
      .where(:elevation.gt => min_elevation)
      .geo_near(self.location)
      .max_distance(max_distance * 1000)
      .spherical
  end

  def seaports(max_distance: 10)
    Seaport
      .geo_near(self.location)
      .max_distance(max_distance * 1000)
      .spherical
  end
end
