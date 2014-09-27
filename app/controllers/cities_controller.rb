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
  expose(:mnt_ele_min) { (query[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (query[:mnt_dis_max] || '500').to_i }

  expose(:use_sea_dis_max) { (query[:use_sea_dis_max] || '1') == '1' }
  expose(:sea_dis_max) { (query[:sea_dis_max] || '20').to_i }

  expose(:use_population) { (query[:use_population] || '1') == '1' }
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
    m0, m1, s0 = mnt_dis_max, mnt_ele_min, sea_dis_max

    self.cities = City
      .where(
        aerosol: aerosol,
        min_temperature: min_temp,
        max_temperature: max_temp
      )

    self.cities = self.cities
      .where(population: population) if use_population

    self.cities = self.cities
      .gt(population: 10 ** 6) if not use_population

    self.cities = self.cities
      .elem_match(seaports_cache: {
        :distance.lt => sea_dis_max * 1000
      }) if use_sea_dis_max

    self.cities = self.cities
      .elem_match(mountains_cache: {
        :distance.lt => m0 * 1000,
        :elevation.gt => m1
      })
      .keep_if do |city|
        city[:seaports_count] =
          city.find_seaports(max_distance: s0).count
        city[:mountains_count] =
          city.find_mountains(max_distance: m0, min_elevation: m1).count
        keep = true
        keep ||= city[:seaports_count] > 0 if use_sea_dis_max
        keep ||= city[:mountains_count] > 2
      end.sort_by do |city|
        score = 0
        score += city[:seaports_count] if use_sea_dis_max
        score += city[:mountains_count]
      end.reverse

    self.cities = Kaminari.paginate_array(self.cities).page(page)

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
