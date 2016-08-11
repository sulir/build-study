#!/usr/bin/env ruby
require 'csv'
require_relative '../experiment/experiment'
require_relative '../experiment/result'
require_relative 'log'

class Analysis
  def initialize(dir)
    @dir = dir
    rows = CSV.read(File.join(@dir, Experiment::RESULTS_FILE), headers: true, converters: :all)
    @results = rows.map { |row| Result.from_hash(row.to_h) }.sort_by(&:name)
    @categories = CSV.read('categories.csv', headers: true).to_a.to_h
  end
  
  def run
    csv = CSV.open(File.join(@dir, 'analyzed.csv'), 'w+', headers: true)
    @results.each do |result|
      result.convert!
      result.error = result.category = nil
      if result.status == false
        file_name = File.join(@dir, 'logs', result.name.sub('/', '_') + '.fail')
        log = Log.new(file_name, result.tool)
        result.error = log.error
        result.category = @categories[result.error] || 'uncategorized'
      end
      result.write(csv)
    end
    csv.close
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.count == 1
    Analysis.new(ARGV[0]).run
  else
    puts 'Usage: ./report.rb results_dir'
  end
end