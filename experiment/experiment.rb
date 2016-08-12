#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'agent'
require 'csv'
require 'fileutils'
require 'webrick'
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
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.include?('-service')
    server = Thread.new { WEBrick::HTTPServer.new(DocumentRoot: Dir.pwd).start }
    Experiment.new.run
    sleep 1
    `tar -czf build.tar.gz *`
    server.join
  else
    Experiment.new.run
  end
end