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
end
