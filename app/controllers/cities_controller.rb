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
  expose(:mnt_ele_min) { (query[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (query[:mnt_dis_max] || '500').to_i }
  expose(:sea_dis_max) { (query[:sea_dis_max] || '20').to_i }

  expose(:population) do
    Range.from_json(query[:population] || '[200000, 500000]')
  end

  expose(:min_temp) do
    Range.from_json(query[:min_temp] || '[-15, 15]')
  end

  expose(:max_temp) do
    Range.from_json(query[:max_temp] || '[15, 30]')
  end

  def index
    query = Regexp.new(Regexp.escape(name), Regexp::IGNORECASE)
    self.cities = cities.where(name: query).desc(:population).page(page)
    respond_with(self.cities)
  end

  def search
    m0, m1, s0 = mnt_dis_max, mnt_ele_min, sea_dis_max

    self.cities = City
      .where(
        is_largest: true,
        population: population,
        min_temperature: min_temp,
        max_temperature: max_temp
      )
      .elem_match(seaports_cache: {
        :distance.lt => s0 * 1000
      })
      .elem_match(mountains_cache: {
        :distance.lt => m0 * 1000,
        :elevation.gt => m1
      })
      .keep_if do |city|
        city[:seaports_count] =
          city.find_seaports(max_distance: s0).count
        city[:mountains_count] =
          city.find_mountains(max_distance: m0, min_elevation: m1).count
        city[:seaports_count] > 0 && city[:mountains_count] > 2
      end.sort_by do |city|
        city[:seaports_count] + city[:mountains_count]
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
