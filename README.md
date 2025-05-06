# Ad Agency Campaign Manager

A system to manage ad campaigns for multiple brands, tracking daily and monthly budgets, and controlling campaign status based on budget limits and dayparting rules.

## Setup

1. Clone this repository
2. Run `bundle install` to install dependencies
3. Run `mkdir -p db && bundle exec ruby app.rb` then visit http://localhost:4567

## Testing

Run tests with `bundle exec rspec`

## Overview

The system manages advertising campaigns for brands with the following features:
- Daily/monthly budget tracking and enforcement
- Campaign activation/deactivation based on budget limits
- Dayparting support (campaigns active only during specific hours)
- Automatic budget resets at day/month boundaries

For more details, see the comments in the code.

