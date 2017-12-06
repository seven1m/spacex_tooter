#!/usr/bin/env ruby

require 'bundler/setup'
require 'open-uri'
require 'nokogiri'
require 'mastodon'
require 'pp'

TOKEN = ENV['TOKEN'] # oauth bearer token
DEBUG = ENV['DEBUG'] # set to true to just print stuff for debugging
TRIES = 10           # how many times to try fetching data
TRY_SLEEP = 10       # seconds to wait for each retry

html = if DEBUG
         File.read('manifest.html')
       else
         try = 0
         begin
           try += 1
           puts 'fetching data...' if DEBUG
           open('https://www.reddit.com/r/spacex/wiki/launches/manifest').read
         rescue OpenURI::HTTPError
           if try <= TRIES
             sleep TRY_SLEEP
             retry
           else
             raise
           end
         end
       end

doc = Nokogiri::HTML(html)

launches = []
headers = nil

doc.css('.wiki table').first.css('tr').each_with_index do |row, index|
  headers = row.css('th').map(&:content) if index.zero?
  launch = row.css('td').each_with_index.each_with_object({}) do |(cell, cell_index), hash|
    hash[headers[cell_index]] = cell.content.strip
  end
  launches << launch unless launch[headers.first].to_s == ''
end

launch = launches.first
launch_window = launch.fetch('NET Date [Launch window UTC]').sub(/\[(\d+:\d+)\]/, '(\1 UTC)')
message = "#{launch_window} launch carrying #{launch.fetch('Payload(s)')} " \
          "into #{launch.fetch('Orbit')} for #{launch.fetch('Customer')} on #{launch.fetch('Vehicle')} " \
          "at launch site #{launch.fetch('Launch site')}"

if DEBUG
  puts 'will toot:'
  puts message
else
  client = Mastodon::REST::Client.new(base_url: 'https://mstdn.io', bearer_token: TOKEN)
  client.perform_request_with_object(
    :post,
    '/api/v1/statuses',
    {
      status: message,
      visibility: 'unlisted'
    },
    Mastodon::Status
  )
end
