require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

CSV.foreach('db/seeds/seaports.csv', headers: true) do |row|
  Seaport.find_or_create_by(
    name: row['name'],
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
end

CSV.foreach('db/seeds/mountains.csv', headers: true) do |row|
  Mountain.find_or_create_by(
    name: row['name'],
    elevation: row['elevation'].to_i,
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
end

CSV.foreach('db/seeds/cities.csv', headers: true) do |row|
  city = City.find_or_create_by(
    name: row['name'],
    country: row['country'],
    elevation: row['elevation'].to_i,
    population: row['population'].to_i,
    precipitations: (1..12).map { |i| row["prec#{i}"].to_i },
    min_temperatures: (1..12).map { |i| row["tmin#{i}"].to_f / 10 },
    max_temperatures: (1..12).map { |i| row["tmax#{i}"].to_f / 10 },
    mean_temperatures: (1..12).map { |i| row["tmean#{i}"].to_f / 10 },
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
  city.min_temperature = city.min_temperatures.min
  city.max_temperature = city.max_temperatures.max
  city.precipitation = city.precipitations.sum
  city.build_seaports
  city.build_mountains
  city.save
end
