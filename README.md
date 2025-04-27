# Ad Agency Campaign Manager

A system to manage ad campaigns for multiple brands, tracking daily and monthly budgets, and controlling campaign status based on budget limits and dayparting rules.

## Overview

This application manages advertising campaigns for multiple brands with the following features:
- Tracks daily and monthly budget spending for each brand
- Automatically turns off campaigns when daily or monthly budgets are reached
- Respects dayparting schedules (campaigns run only during specific hours)
- Reactivates campaigns at the start of a new day or month if budget allows

## Technologies
- Sinatra framework
- SQLite database
- dry-rb for models
- Plain JavaScript
- Tailwind CSS via CDN
- RSpec for testing

## Setup Instructions

1. Clone this repository
2. Run `bundle install` to install dependencies
3. Run `rake db:setup` to create and seed the database
4. Start the server with `bundle exec rackup`
5. Visit `http://localhost:9292` in your browser

## Testing

Run tests with `bundle exec rspec`

## Assumptions

- The system runs a periodic check (e.g., every 15 minutes) to update campaign status
- Budget periods reset at midnight for daily budgets and at the first day of each month for monthly budgets
- All times are in the server's local timezone

