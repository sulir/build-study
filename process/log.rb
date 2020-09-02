class Log
  def self.new(file_name, tool)
    object = Object.const_get(tool + 'Log').allocate
    object.send(:initialize, file_name)
    object
  end

  def initialize(file_name)
    @text = File.read(file_name)
  end
end
