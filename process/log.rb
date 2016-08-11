class Log
  ANT_PATTERNS = {
    :CannotImport => /: Cannot find .* imported from/,
    :MissingPath => /: Path to 'platform' cluster missing/,
    :TargetDoesNotExist => /^Target ".*" does not exist in the project ".*"\./,
    :TaskdefNotFound => /: taskdef class .* cannot be found/
  }
  
  def initialize(file_name, tool)
    @text = File.read(file_name)
    @tool = tool
  end
  
  def error
    send('error_' + @tool) || 'unknown'
  end
  
  private
  def error_Gradle
    lines = @text.lines
    start_index = lines.rindex("* Exception is:\n")
    end_index = lines.rindex("BUILD FAILED\n") || -1
    trace = lines[start_index..end_index]
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
  
  def error_Maven
    class_name = @text.scan(/^\[ERROR\] \[Help \d\] http:\/\/.*\/(\w+)$/).flatten.last or return
    type = class_name.chomp('Exception').chomp('Error')
    
    if %w(MojoFailure MojoExecution PluginExecution).include?(type)
      @text =~ /^\[ERROR\] Failed to execute goal [^:]+:([^:]+):[^:]+:[^:]+ \([^)]+\) on project/
      type += ":#{$1}"
    end
    
    type
  end
  
  def error_Ant
    builds = @text.split(/Total time: [^\n]+ seconds\nBuildfile: \/[^\n]+\n/m).drop(1)
    output = builds.find { |build|
      build !~ /BUILD FAILED\nTarget "(jar|war|dist)" does not exist in the project "[^\n]*"\./m
    } || builds.last
    targets = output.scan(/^([\w.-]+):$/)
    if targets.empty?
      matching = ANT_PATTERNS.find { |_, pattern| output =~ pattern }
      matching.first.to_s if matching
    else
      'Target:' + targets.last[0]
    end
  end
end
