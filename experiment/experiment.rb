#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'agent'
require 'csv'
require 'fileutils'
require_relative 'service'

class Experiment
  BUILD_DIR = '/tmp/build/'
  LOG_DIR = File.join(Dir.pwd, 'logs')
  RESULTS_FILE = 'results.csv'
  
  def initialize
    Thread.abort_on_exception = true
    create_empty(BUILD_DIR)
    create_empty(LOG_DIR)
    @channel = channel!(Object, 5)
  end
  
  def run
    @log = File.open('log.txt', 'w')
    @csv = CSV.open(RESULTS_FILE, 'w+', headers: true)
    @log.sync = @csv.sync = true
    @progress = Hash.new(0)
    go! { download_all }
    build_all
    @csv.close
    @log.close
  end
  
  def download_all
    service = Service.new(@log)
    remaining = (ARGV[0] || 10).to_i
    while remaining > 0 do
      repo = service.random_repo
      project = nil
      log('DWNLD', repo) { project = repo.download }
      if project
        if !project.ignore?
          @channel << project
          remaining -= 1
        else
          project.erase
        end
      end
    end
    @channel << nil
  end
  
  def build_all
    until (project = @channel.receive.first).nil?
      log('BUILD', project.repo) do
        result = project.build
        result.write(@csv)
        project.erase
        erase_cache_if_disk_full
      end
    end
  end
  
  def log(action, repo)
    begin
      message = "#{action}\t%s\t#{@progress[action] += 1}\t#{repo.name}\n"
      @log.printf(message, 'START')
      yield
      @log.printf(message, 'END')
    rescue => error
      @log.puts error, error.backtrace
    end
  end
  
  def create_empty(dir)
    FileUtils.makedirs(dir)
    FileUtils.rm_rf(Dir[File.join(dir, '*')])
  end

  def erase_cache_if_disk_full
    free_megabytes = `df -m --output=avail #{Dir.home}`.lines[1].to_i
    if free_megabytes < 4096
      Dir.chdir(Dir.home) do
        FileUtils.rm_rf(['.gradle', '.m2', '.ant', '.ivy2'])
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ENV['GITHUB_TOKEN']
    Experiment.new.run
  else
    puts "Please supply a GitHub token via the GITHUB_TOKEN environment variable. See:",
      "1. https://github.com/settings/tokens/new (do not select any scopes)",
      "2. https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file"
  end
end
