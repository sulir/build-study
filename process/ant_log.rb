require_relative 'log'

class AntLog < Log
  PATTERNS = {
    :CannotImport => /: Cannot find .* imported from/,
    :MissingPath => /: Path to 'platform' cluster missing/,
    :TargetDoesNotExist => /^Target ".*" does not exist in the project ".*"\./,
    :TaskdefNotFound => /: taskdef class .* cannot be found/
  }

  def error_type
    @output ||= failing_run
    targets = @output.scan(/^([\w.-]+):$/)

    if targets.empty?
      matching = PATTERNS.find { |_, pattern| @output =~ pattern }
      matching.first.to_s if matching
    else
      'Target:' + targets.last[0]
    end
  end

  def compiler_message
    @output ||= failing_run

    error_line = @output.lines.find { |line| line =~ /^\s*\[javac\].* error: (.*)$/ }
    $1 if error_line
  end

  private
  def failing_run
    runs = @text.split(/Total time: [^\n]+ seconds\nBuildfile: \/[^\n]+\n/m).drop(1)
    first_existing = runs.find do |run|
      run !~ /BUILD FAILED\nTarget "(jar|war|dist)" does not exist in the project "[^\n]*"\./m
    end
    first_existing || runs.last
  end
end
