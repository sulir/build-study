#!/usr/bin/env ruby
require 'csv'
require_relative '../experiment/result'
require_relative 'ant_log'
require_relative 'gradle_log'
require_relative 'maven_log'

class Analysis
  def initialize(dir)
    @dir = dir
    rows = CSV.read(File.join(@dir, 'results.csv'), headers: true, converters: :all)
    @results = rows.map { |row| Result.from_hash(row.to_h) }.sort_by(&:name)
    @categories = CSV.read(File.join(__dir__, 'categories.csv'), headers: true).to_a.to_h
  end
  
  def run
    csv = CSV.open(File.join(@dir, 'builds.csv'), 'w+', headers: true)
    @results.each do |result|
      result.convert!
      result.compiler_message = result.error_type = result.error_category = nil
      if result.status == false
        file_name = File.join(@dir, 'logs', result.name.sub('/', '_') + '.fail')
        log = Log.new(file_name, result.tool)
        result.error_type = log.error_type || 'unknown'
        result.error_category = @categories[result.error_type] || 'uncategorized'
        if result.error_category == 'Java compilation'
          result.compiler_message = shorten(log.compiler_message) || 'unknown'
        end
      end
      result.write(csv)
    end
    csv.close
  end

  private
  def shorten(message)
    if message && message.length > 200
      packages_omitted = message.gsub(/[a-z.]+\.([A-Z]\w+)/, '...\1')
      paths_omitted = packages_omitted.gsub(/\/[\w\/-]+\//, '.../')
      return paths_omitted
    else
      return message
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.count == 1
    Analysis.new(ARGV[0]).run
  else
    puts 'Usage: analysis.rb results_dir'
  end
end
