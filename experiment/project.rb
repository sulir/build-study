require 'fileutils'
require_relative 'result'

class Project
  TOOLS = [
    ['Gradle', 'build.gradle', 'GRADLE=gradle; [ -f gradlew ] && GRADLE="sh gradlew";' +
      ' $GRADLE clean assemble --no-daemon -s --console=plain'],
    ['Maven', 'pom.xml', 'mvn clean package -DskipTests --batch-mode'],
    ['Ant', 'build.xml', 'ant clean; ant jar || ant war || ant dist || ant']]
  IGNORE = [
    ['**/*.java', 'import android.'],
    ['**/AndroidManifest.xml', ''],
    ['**/*.java', 'import javax.microedition.'],
    ['**/*.{c,cc,cpp,cxx}', 'JNIEXPORT']]
  TECHNOLOGIES = [
    ['Ant', '**/build.xml'],
    ['Buildr', '**/[bB]uildfile'],
    ['Gradle', '**/build.gradle'],
    ['Make', '**/{GNUm,[mM]}akefile'],
    ['Maven', '**/pom.xml'],
    ['SBT', '**/{build.sbt,project/[bB]uild.scala}'],
    ['Ivy', '**/ivy{,settings*}.xml'],
    ['Eclipse', '**/.project'],
    ['IntelliJ IDEA', '**/.{idea,ipr}'],
    ['NetBeans', '**/nbproject'],
    ['Travis CI', '.travis.yml'],
    ['Git submodules', '**/.gitmodules']]
  attr_reader :repo, :input_files, :output_files
  
  def initialize(repo, dir)
    @repo, @dir = repo, dir
    @files = {}
  end
  
  def ignore?
    IGNORE.any? do |file_pattern, content|
      Dir[File.join(@dir, file_pattern)].any? do |file_name|
        File.file?(file_name) && File.read(file_name).include?(content)
      end
    end
  end
  
  def tool
    @tool ||= (TOOLS.find { |_, file| Dir[File.join(@dir, file)].any? } || [''])[0]
  end
  
  def build
    @input_files = @output_files = file_list
    return Result.from_build(self, nil) if tool.empty?
    command = TOOLS.find { |name, _| name == tool }[2]
    Dir.chdir(@dir) do
      `timeout -k1m 1h unbuffer bash -c '#{command}' </dev/null >'#{log_path}' 2>&1`
    end
    File.rename(log_path, log_path + ($?.exitstatus.zero? ? '.pass' : '.fail'))
    @output_files = file_list
    Result.from_build(self, $?.exitstatus)
  end
  
  def technologies
    TECHNOLOGIES.map { |name, file_pattern|
      [name, Dir[File.join(@dir, file_pattern)].any?]
    }.to_h
  end
  
  def new_files
    output_files - input_files
  end
  
  def erase
    FileUtils.rm_rf(@dir)
  end
  
  private
  def log_path
    File.join(Experiment::LOG_DIR, repo.name.sub('/', '_'))
  end
  
  def file_list
    Dir.glob(File.join(@dir, '**/{[^.]*,.?*}')).map do |path|
      path[(@dir.length + 1)..-1]
    end
  end
end
