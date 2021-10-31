# frozen_string_literal: true

require "forwardable"

module Project
  class Spec
    extend Forwardable

    def_delegators :@gemspec, :name, :version

    def initialize(basename)
      @basename = basename

      gemspec_file = "#{basename}.gemspec"
      @gemspec = Bundler.load_gemspec(gemspec_file)

      set_up_git
    end

    def build_gem
      shell "Building gem", "gem build #{@basename}.gemspec"
      self
    end

    def publish
      git_tag = "v#{version}"

      shell "Creating Tag #{git_tag.inspect}", %(git tag #{git_tag} -m "Release :gem: #{git_tag}")
      shell "Publishing Tag", "git push origin #{git_tag}"
      shell "Publishing Gem", "gem push #{name}-#{version}.gem"
      self
    end

    private

    def set_up_git
      system %(git config user.name "#{ENV["ACTOR"]}")
      system %(git config user.email "#{ENV["ACTOR"]}@users.noreply.github.com")
    end

    def shell(message, command)
      puts ""
      puts "#{message}..."
      system command
    rescue => e
      puts "Error #{message.downcase}"
      puts e
      exit
    end
  end
end

Dir.chdir(ENV["WORKSPACE"]) do
  Project::Spec.new(ENV["GEMSPEC_NAME"]).build_gem.publish
end
