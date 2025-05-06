# frozen_string_literal: true

require 'sinatra'
require 'sqlite3'
require 'json'
require 'rufus-scheduler'

configure do
  set :database, SQLite3::Database.new("db/ad_agency_#{settings.environment}.db")
  settings.database.results_as_hash = true
  set :scheduler, Rufus::Scheduler.new
end

def load_data
  JSON.parse(File.read('data.json'))
end

def save_data(data)
  File.write('data.json', JSON.pretty_generate(data))
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

  def find_brand(brand_id)
    brands.find { |brand| brand['id'] == brand_id }
  end

  def find_campaign(campaign_id)
    campaigns.find { |campaign| campaign['id'] == campaign_id }
  end

  def update_stats
    active_count = campaigns.count { |campaign| campaign['status'] == 'Active' }
    total_spend = brands.sum { |brand| brand['daily_spend'] }

    data['stats']['active_campaigns'] = active_count
    data['stats']['total_daily_spend'] = total_spend

    save_data(data)
  end
end

def daily_budget_exceeded?(brand)
  brand['daily_spend'] >= brand['daily_budget']
end

def monthly_budget_exceeded?(brand)
  brand['monthly_spend'] >= brand['monthly_budget']
end

def within_dayparting_hours?(campaign)
  current_hour = Time.now.hour
  campaign['start_hour'] <= current_hour && current_hour < campaign['end_hour']
end

def turn_off_campaign(campaign)
  return unless campaign['status'] == 'Active'

  campaign['status'] = 'Inactive'
  save_data(data)
  update_stats
end

def turn_on_campaign(campaign)
  return unless campaign['status'] == 'Inactive'

  campaign['status'] = 'Active'
  save_data(data)
  update_stats
end

def turn_off_brand_campaigns(brand_id)
  campaigns.each do |campaign|
    turn_off_campaign(campaign) if campaign['brand_id'] == brand_id
  end
end

def check_and_update_campaign_status
  brands.each do |brand|
    if monthly_budget_exceeded?(brand)
      turn_off_brand_campaigns(brand['id'])
      next
    end

    if daily_budget_exceeded?(brand)
      turn_off_brand_campaigns(brand['id'])
      next
    end

    campaigns.each do |campaign|
      if campaign['brand_id'] == brand['id']
        if within_dayparting_hours?(campaign)
          turn_on_campaign(campaign)
        else
          turn_off_campaign(campaign)
        end
      end
    end
  end
end

def record_spend(campaign_id, amount)
  campaign = find_campaign(campaign_id)
  return unless campaign

  campaign['daily_spend'] = campaign['daily_spend'] + amount

  brand = find_brand(campaign['brand_id'])
  return unless brand

  brand['daily_spend'] = brand['daily_spend'] + amount
  brand['monthly_spend'] = brand['monthly_spend'] + amount

  save_data(data)
  update_stats

  check_and_update_campaign_status
end

def reset_daily_budgets
  brands.each do |brand|
    brand['daily_spend'] = 0
  end

  campaigns.each do |campaign|
    campaign['daily_spend'] = 0
  end

  save_data(data)
  update_stats

  check_and_update_campaign_status
end

def reset_monthly_budgets
  brands.each do |brand|
    brand['monthly_spend'] = 0
  end

  save_data(data)
  update_stats

  check_and_update_campaign_status
end

settings.scheduler.every '15m' do
  check_and_update_campaign_status
end

settings.scheduler.cron '0 0 * * *' do
  reset_daily_budgets
end

settings.scheduler.cron '0 0 1 * *' do
  reset_monthly_budgets
end

get '/' do
  erb :index
end

get '/api/data' do
  content_type :json
  JSON.generate(data)
end

post '/api/record_spend' do
  campaign_id = params[:campaign_id].to_i
  amount = params[:amount].to_f

  record_spend(campaign_id, amount)

  redirect '/'
end

get '/api/reset_daily' do
  reset_daily_budgets
  redirect '/'
end

get '/api/reset_monthly' do
  reset_monthly_budgets
  redirect '/'
end

get '/api/check_status' do
  check_and_update_campaign_status
  redirect '/'
end
