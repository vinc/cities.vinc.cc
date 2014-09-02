require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

CSV.foreach('db/seeds/cities.csv', headers: true, col_sep: ', ') do |row|
  City.create(
    name: row['name'],
    country: row['country'],
    elevation: row['elevation'].to_i,
    population: row['population'].to_i,
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
end

CSV.foreach('db/seeds/seaports.csv', headers: true, col_sep: ', ') do |row|
  Seaport.create(
    name: row['name'],
    country: row['country'],
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
end

CSV.foreach('db/seeds/mountains.csv', headers: true, col_sep: ', ') do |row|
  Mountain.create(
    name: row['name'],
    elevation: row['elevation'].to_i,
    location: {
      type: 'Point',
      coordinates: [row['longitude'].to_f, row['latitude'].to_f]
    }
  )
end
