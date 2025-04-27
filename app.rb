# frozen_string_literal: true

require 'sinatra'
require 'sqlite3'
require 'json'

configure do
  set :database, SQLite3::Database.new("db/ad_agency_#{settings.environment}.db")
  settings.database.results_as_hash = true
end

def load_data
  JSON.parse(File.read('data.json'))
end

helpers do
  def db
    settings.database
  end

  def data
    @data ||= load_data
  end

  def brands
    data['brands']
  end

  def campaigns
    data['campaigns']
  end

  def stats
    data['stats']
  end

  def brand_name(brand_id)
    brands.find { |brand| brand['id'] == brand_id }['name']
  end

  def format_hours(start_hour, end_hour)
    "#{start_hour}:00 - #{end_hour}:00"
  end
end

get '/' do
  erb :index
end

get '/api/data' do
  content_type :json
  JSON.generate(data)
end
