class City < Point
  include Elasticsearch::Model

  field :country, type: Country
  field :elevation, type: Integer
  field :population, type: Integer
  field :aerosol, type: Integer

  field :min_temperature, type: Integer
  field :min_temperatures, type: Array

  field :max_temperature, type: Integer
  field :max_temperatures, type: Array

  field :mean_temperatures, type: Array

  field :precipitations, type: Array
  field :precipitation, type: Integer

  field :mountains_cache, type: Array
  field :seaports_cache, type: Array
  field :airports_cache, type: Array

  mapping do
    indexes :id, index: :not_analyzed
    indexes :name, analyzer: 'snowball'
    indexes :location, type: :geo_shape
  end

  def as_indexed_json(options={})
    self.as_json(only: %i(name location))
  end

  def title
    "#{self.name}, #{self.country}"
  end

  def mountains
    @mountains ||= find_mountains
  end

  def seaports
    @seaports ||= find_seaports
  end

  def airports
    @airports ||= find_airports
  end

  def find_mountains(max_distance: 500, min_elevation: 2500)
    d = max_distance * 1000
    e = min_elevation
    ids = self.mountains_cache.reduce([]) do |r, h|
      h[:distance] < d && h[:elevation] >= e ? r << h[:id] : r
    end
    @mountains = docs_with_distances(Mountain.in(id: ids), self.mountains_cache)
  end

  def find_seaports(max_distance: 20)
    d = max_distance * 1000
    ids = self.seaports_cache.reduce([]) do |r, h|
      h[:distance] < d ? r << h[:id] : r
    end
    docs_with_distances(Seaport.in(id: ids), self.seaports_cache)
  end

  def find_airports(max_distance: 50)
    d = max_distance * 1000
    ids = self.airports_cache.reduce([]) do |r, h|
      h[:distance] < d ? r << h[:id] : r
    end
    docs_with_distances(Airport.in(id: ids), self.airports_cache)
  end

  def build_mountains
    keys = %i(id elevation distance) # Attributes stored in cache
    self.mountains_cache = Mountain
      .within_sphere(center: self.location, radius: 1000 * 1000)
      .map { |doc| Hash[keys.map { |key| [key, doc.send(key)] }] }
  end

  def build_seaports
    keys = %i(id distance) # Attributes stored in cache
    self.seaports_cache = Seaport
      .within_sphere(center: self.location, radius: 50 * 1000)
      .map { |doc| Hash[keys.map { |key| [key, doc.send(key)] }] }
  end

  def build_airports
    keys = %i(id distance) # Attributes stored in cache
    self.airports_cache = Airport
      .within_sphere(center: self.location, radius: 100 * 1000)
      .map { |doc| Hash[keys.map { |key| [key, doc.send(key)] }] }
  end

  private

  def docs_with_distances(docs, cache)
    distances = cache.reduce({}) do |r, h|
      r.merge({ h[:id] => h[:distance] })
    end
    # FIXME: the sort istead of a map is only needed because the .in() used
    # to select docs does not retains order.
    docs.sort_by do |doc|
      doc[:geo_near_distance] = distances[doc.id]
    end
  end
end
