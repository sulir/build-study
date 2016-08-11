require 'ostruct'

class Result < OpenStruct
  CSV_MAP = {true => 'T', false => 'F', nil => 'NA'}
  
  def self.from_build(project, status_code)
    new([{name: project.repo.name,
          status: (status_code.zero? if status_code),
          code: status_code,
          tool: project.tool},
         project.repo.to_h.reject { |key| key == :url },
         project.technologies,
         {in_files: project.input_files.count,
          out_files: project.output_files.count,
          new_files: project.new_files.count}].reduce(:merge))
  end
  
  def self.from_hash(hash)
    converted = hash.map do |key, value|
      [key, CSV_MAP.has_value?(value) ? CSV_MAP.key(value) : value]
    end
    new(converted.to_h)
  end
  
  def write(csv)
    csv << to_h.keys if csv.pos.zero? && csv.eof?
    csv << to_h.values.map do |value|
      CSV_MAP.key?(value) ? CSV_MAP[value] : value
    end
  end
  
  def convert!
    self.status = nil if self.code == 124
    self.tool = nil if self.tool == ''
  end
end