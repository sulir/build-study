require_relative 'log'

class GradleLog < Log
  def error_type
    @lines ||= @text.lines

    start_index = @lines.rindex("* Exception is:\n")
    end_index = @lines.rindex("BUILD FAILED\n") || -1
    trace = @lines[start_index..end_index]
    exception = trace.find { |line| line =~ /^Cause(d by| \d+): ([^:]+:.*)/ }
    exception &&= $2
    exception ||= trace[1]
    class_name = exception.match(/([^.\$]+?)(: (.+))?$/)[1]
    type = class_name.chomp('Exception').chomp('Error')
    
    if %w(Gradle TaskExecution).include?(type)
      @text =~ /Execution failed for task '.*:(.*)'\./
      type += ":#{$1}"
    elsif %w(PluginApplication).include?(type)
      @text =~ /Failed to apply plugin \[(class|id) '[^']*?([^'.]+)'\]/
      type += ":#{$2}"
    end
    
    type
  end

  def compiler_message
    @lines ||= @text.lines

    java_index = @lines.index { |line| line =~ /^> Task .*:compileJava/ }
    java_lines = @lines[java_index..-1]

    error_line = java_lines.find { |line| line =~ /\berror: (.*)$/ }
    $1 if error_line
  end
end
