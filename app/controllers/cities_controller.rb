module RangeToString
  refine Range do
    def to_s
      [self.first, self.last].to_s
    end

    def self.from_json(json)
      min, max = JSON.parse(json)
      (min..max)
    end
  end
end

# FIXME: (1..3).to_s work without this monkey patch, but not "#{(1..3)}"
class Range
  def to_s
    [self.first, self.last].to_s
  end

  def self.from_json(json)
    min, max = JSON.parse(json)
    (min..max)
  end
end

class CitiesController < ApplicationController
  using RangeToString

  respond_to(:json, :html)

  expose(:cities)
  expose(:city)
  expose(:page) { (params[:page] || '1').to_i }

  expose(:query) { params[:query] || {} }
  expose(:name) { query[:name] || '' }
  expose(:bbox) do
    bbox = (query[:bbox] || '-180,-90,180,90').split(',').map(&:to_f)
    bbox[0] = -180 if bbox[0] < -180
    bbox[2] = 180 if bbox[2] > 180
    bbox = [[bbox[0], bbox[3]], [bbox[2], bbox[1]]]
  end

  expose(:search_mountains) { (query[:search_mountains] || '1') == '1' }
  expose(:mnt_ele_min) { (query[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (query[:mnt_dis_max] || '500').to_i }

  expose(:search_seaports) { (query[:search_seaports] || '1') == '1' }
  expose(:sea_dis_max) { (query[:sea_dis_max] || '20').to_i }

  expose(:search_population) { (query[:search_population] || '1') == '1' }
  expose(:population) do
    Range.from_json(query[:population] || '[200000, 500000]')
  end

  expose(:aerosol) do
    Range.from_json(query[:aerosol] || '[0, 10]')
  end

  expose(:min_temp) do
    Range.from_json(query[:min_temp] || '[-15, 15]')
  end

  expose(:max_temp) do
    Range.from_json(query[:max_temp] || '[15, 30]')
  end

  def index
    query = if name.empty?
      {
        match_all: {}
      }
    else
      {
        match: {
          name: {
            query: name,
            operator: 'and',
            fuzziness: 1
          }
        }
      }
    end

    filtered_query = {
      filtered: {
        query: query,
        filter: {
          geo_shape: {
            location: {
              shape: {
                type: 'envelope',
                coordinates: bbox
              }
            }
          }
        }
      }
    }

    sort = { population: 'desc' }

    scope = City.search(sort: sort, query: filtered_query)
    scope = City.search(sort: sort, query: query) if scope.count == 0
    self.cities = scope.page(page).records
    respond_with(self.cities)
  end

  def search
    scope = City
      .where(
        aerosol: aerosol,
        min_temperature: min_temp,
        max_temperature: max_temp
      )

    scope = scope
      .where(population: population) if search_population

    scope = scope
      .gt(population: 10 ** 6) if not search_population

    scope = scope
      .elem_match(seaports_cache: {
        :distance.lt => sea_dis_max * 1000
      }) if search_seaports

    scope = scope
      .elem_match(mountains_cache: {
        :distance.lt => mnt_dis_max * 1000,
        :elevation.gt => mnt_ele_min
      }) if search_mountains

    self.cities = scope.asc(:name).page(page)

    respond_with(self.cities)
  end

  def show
    self.cities = [city] # Needed for map
    respond_with(city)
  end

  def welcome
    self.cities = [] # Needed for map
  end
end
