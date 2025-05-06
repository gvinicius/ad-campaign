# frozen_string_literal: true

require 'spec_helper'

describe 'Ad Agency Campaign Manager App' do
  before do
    data = {
      'brands' => [
        {
          'id' => 1,
          'name' => 'Test Brand',
          'daily_budget' => 100.00,
          'monthly_budget' => 3000.00,
          'daily_spend' => 0.0,
          'monthly_spend' => 0.0,
          'status' => 'Active'
        }
      ],
      'campaigns' => [
        {
          'id' => 1,
          'name' => 'Test Campaign',
          'brand_id' => 1,
          'start_hour' => 0,
          'end_hour' => 23,
          'daily_spend' => 0.0,
          'status' => 'Active'
        }
      ],
      'stats' => {
        'total_brands' => 1,
        'active_campaigns' => 1,
        'total_daily_spend' => 0.0
      }
    }

    allow_any_instance_of(Sinatra::Application).to receive(:data).and_return(data)
    allow_any_instance_of(Sinatra::Application).to receive(:save_data).and_return(true)
    allow_any_instance_of(Sinatra::Application).to receive(:update_stats).and_return(true)
  end

  describe 'GET /' do
    it 'loads the dashboard' do
      get '/'
      expect(last_response.status).to eq 200
      expect(last_response.body).to include('Ad Agency Campaign Manager')
      expect(last_response.body).to include('Test Brand')
      expect(last_response.body).to include('Test Campaign')
    end
  end

  describe 'POST /api/record_spend' do
    it 'records spend for a campaign' do
      allow_any_instance_of(Sinatra::Application).to receive(:check_and_update_campaign_status).and_return(true)

      post '/api/record_spend', { campaign_id: 1, amount: 50.0 }
      expect(last_response.status).to eq 302 # Redirect
    end
  end

  describe 'Budget exceeded checks' do
    it 'identifies when daily budget is exceeded' do
      brand = { 'daily_spend' => 100.0, 'daily_budget' => 100.0 }
      expect(daily_budget_exceeded?(brand)).to be true

      brand = { 'daily_spend' => 99.9, 'daily_budget' => 100.0 }
      expect(daily_budget_exceeded?(brand)).to be false
    end

    it 'identifies when monthly budget is exceeded' do
      brand = { 'monthly_spend' => 3000.0, 'monthly_budget' => 3000.0 }
      expect(monthly_budget_exceeded?(brand)).to be true

      brand = { 'monthly_spend' => 2999.9, 'monthly_budget' => 3000.0 }
      expect(monthly_budget_exceeded?(brand)).to be false
    end
  end

  describe 'Dayparting checks' do
    it 'checks if campaign is within dayparting hours' do
      # This test will depend on the current hour, so we need to be flexible
      current_hour = Time.now.hour

      campaign = { 'start_hour' => 0, 'end_hour' => 24 }
      expect(within_dayparting_hours?(campaign)).to be true

      campaign = { 'start_hour' => current_hour, 'end_hour' => current_hour + 1 }
      expect(within_dayparting_hours?(campaign)).to be true

      campaign = { 'start_hour' => current_hour + 1, 'end_hour' => current_hour + 2 }
      expect(within_dayparting_hours?(campaign)).to be false
    end
  end
end
