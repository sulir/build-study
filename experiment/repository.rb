require 'fileutils'
require_relative 'project'
require_relative 'service'

class Repository < Struct.new(:name, :url, :stars, :forks, :created, :pushed)
  def self.from_response(repo)
    new(
      repo.full_name,
      repo.rels[:archive].href(archive_format: 'tarball'),
      repo.stargazers_count,
      repo.forks,
      repo.created_at.to_s,
      repo.pushed_at.to_s
    )
  end
  
  def download
    local = File.join(Experiment::BUILD_DIR, name.sub('/', '_'))
    FileUtils.makedirs(local)
    `curl -sL "#{url}?access_token=#{Service::ACCESS_TOKEN}"\
     | tar -xzC "#{local}" --strip-components=1 --warning=no-timestamp`
    $?.exitstatus.zero? or raise "Download error"
    Project.new(self, local)
  end
end
