require 'date'
require 'octokit'
require_relative 'repository'

class Service
  ACCESS_TOKEN = '20e0b799d236ec0dd76b24f255ee41d3a9d36e24'
  
  def initialize(log)
    @log = log
    @github = Octokit::Client.new(access_token: ACCESS_TOKEN, auto_paginate: true)
  end
  
  def random_repo
    @repo_list ||= repo_list.shuffle
    loop do
      repo_name = @repo_list.pop
      repo = request do
        @github.repo(repo_name)
      end
      if repo && repo.forks > 0 && !repo.license.nil? && repo.license.name != 'Other'
        return Repository.from_response(repo) 
      end
    end
  end
  
  private
  def repo_list
    repos = []
    Date.new(2008, 02, 27).upto(Date.today) do |date|
      query = "language:Java forks:>0 created:#{date}"
      result = request { @github.search_repos(query) }
      @log.puts("Incomplete results! Date: " + date.to_s) if result.incomplete_results
      repos += result.items.map(&:full_name)
    end
    repos.uniq
  end
  
  def request
    loop do
      begin
        return yield
      rescue Octokit::TooManyRequests
        sleep @github.rate_limit.resets_in
      rescue Octokit::ClientError
        return
      rescue => error
        @log.puts error, error.backtrace
        sleep 15 * 60
      end
    end
  end
end
