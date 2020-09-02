require_relative 'log'

class AntLog < Log
  PATTERNS = {
    :CannotImport => /: Cannot find .* imported from/,
    :MissingPath => /: Path to 'platform' cluster missing/,
    :TargetDoesNotExist => /^Target ".*" does not exist in the project ".*"\./,
    :TaskdefNotFound => /: taskdef class .* cannot be found/
  }

  def error_type
    builds = @text.split(/Total time: [^\n]+ seconds\nBuildfile: \/[^\n]+\n/m).drop(1)
    output = builds.find { |build|
      build !~ /BUILD FAILED\nTarget "(jar|war|dist)" does not exist in the project "[^\n]*"\./m
    } || builds.last
    targets = output.scan(/^([\w.-]+):$/)
    if targets.empty?
      matching = PATTERNS.find { |_, pattern| output =~ pattern }
      matching.first.to_s if matching
    else
      'Target:' + targets.last[0]
    end
  end
end
