# frozen_string_literal: true

require 'spec_helper'

describe 'Ad Agency Campaign Manager App' do
  before do
    allow_any_instance_of(Sinatra::Application).to receive(:load_data).and_return({
                                                                                    'brands' => [
                                                                                      {
                                                                                        'id' => 1,
                                                                                        'name' => 'Nike',
                                                                                        'daily_budget' => 100.00,
                                                                                        'monthly_budget' => 3000.00,
                                                                                        'daily_spend' => 45.75,
                                                                                        'monthly_spend' => 1250.25,
                                                                                        'status' => 'Active'
                                                                                      }
                                                                                    ],
                                                                                    'campaigns' => [
                                                                                      {
                                                                                        'id' => 1,
                                                                                        'name' => 'Nike Running',
                                                                                        'brand_id' => 1,
                                                                                        'start_hour' => 8,
                                                                                        'end_hour' => 20,
                                                                                        'daily_spend' => 25.50,
                                                                                        'status' => 'Active'
                                                                                      }
                                                                                    ],
                                                                                    'stats' => {
                                                                                      'total_brands' => 1,
                                                                                      'active_campaigns' => 1,
                                                                                      'total_daily_spend' => 45.75
                                                                                    }
                                                                                  })
  end

  describe 'GET /' do
    it 'loads the dashboard' do
      get '/'
      expect(last_response.status).to eq 200
      expect(last_response.body).to include('Ad Agency Campaign Manager')
      expect(last_response.body).to include('Nike')
      expect(last_response.body).to include('Nike Running')
    end
  end

  describe 'GET /api/data' do
    it 'returns JSON data' do
      get '/api/data'
      expect(last_response.status).to eq 200
      expect(last_response.headers['Content-Type']).to include('application/json')

      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body['brands'].length).to eq 1
      expect(parsed_body['campaigns'].length).to eq 1
      expect(parsed_body['stats']['total_brands']).to eq 1
    end
  end

  describe 'Helper methods' do
    it 'formats hours correctly' do
      helper = Object.new
      helper.extend Sinatra::Helpers

      app_instance = Sinatra::Application.new
      allow(helper).to receive(:format_hours).and_return(app_instance.helpers.format_hours(9, 17))

      expect(helper.format_hours).to eq '9:00 - 17:00'
    end

    it 'finds brand name by ID' do
      helper = Object.new
      helper.extend Sinatra::Helpers

      app_instance = Sinatra::Application.new
      allow(helper).to receive(:brand_name).and_return(app_instance.helpers.brand_name(1))

      expect(helper.brand_name).to eq 'Nike'
    end
  end
end
