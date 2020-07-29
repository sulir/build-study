#!/usr/bin/env ruby

require 'csv'
require 'octokit'
require_relative 'service'

if __FILE__ == $PROGRAM_NAME
    rows = CSV.read(File.join(ARGV[0], 'results.csv'), headers: true, converters: :all)
    github = Octokit::Client.new(access_token: Service::ACCESS_TOKEN,
        auto_paginate: true, per_page: 100)
    out = CSV.open(File.join(ARGV[0], 'docker.csv'), 'w')
    out.sync = true
    
    out << ['name', 'Dockerfile']
    rows.each do |row|
        name = row['name']
        begin
            github.contents(name, path: 'Dockerfile')
            out << [name, 'T']
        rescue Octokit::NotFound
            out << [name, 'F']
        rescue Octokit::TooManyRequests
            sleep github.rate_limit.resets_in
            retry
        rescue => error
            print error
        end
    end
end