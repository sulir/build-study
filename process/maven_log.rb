require_relative 'log'

class MavenLog < Log
  def error_type
    class_name = @text.scan(/^\[ERROR\] \[Help \d\] http:\/\/.*\/(\w+)$/).flatten.last or return
    type = class_name.chomp('Exception').chomp('Error')
    
    if %w(MojoFailure MojoExecution PluginExecution).include?(type)
      @text =~ /^\[ERROR\] Failed to execute goal [^:]+:([^:]+):[^:]+:[^:]+ \([^)]+\) on project/
      type += ":#{$1}"
    end
    
    type
  end

  def compiler_message
    message = nil
    error_lines = @text.lines.grep(/^\[ERROR\] /).map { |line| line.sub('[ERROR]', '').strip }
    error_lines.reject! { |line| line.empty? }
    compilation_index = error_lines.index do | line |
      line =~ /Compilation failure:?$/
    end

    if compilation_index
      error_line = error_lines[compilation_index + 1]
      message = remove_location(error_line)
      if message.empty? || message.start_with?('1. ERROR in ')
        message = error_lines[compilation_index + 4]
      elsif message == '-options.'
        message = remove_location(error_lines[compilation_index + 2])
      end
    else
      error_lines.find do |line|
        line =~ /Fatal error compiling: (.*) -> \[Help \d+\]$/
        message = $1
      end
    end

    message.sub(/^error: /, '') if message && !message.start_with?('-', '?')
  end

  private
  def remove_location(line)
    line.sub(/(.*?\[-?\d+(,-?\d+)?\]|.*\.java:) ?/, '').sub(/\s*\tat.*$/, '')
  end
end
