# frozen_string_literal: true
require "fileutils"
require "pathname"

RSpec.describe LocalGems do
  include FileUtils

  it "has a version number" do
    expect(LocalGems::VERSION).not_to be nil
  end

  describe "exe/local_gems --init" do
    around :example do |example|
      in_temp_dir(&example)
    end

    it "symlinks the Gemfile to Gemfile.lock" do
      system "touch Gemfile"
      local_gems "--init"

      gemfile = Pathname.new("Gemfile")
      local_gemfile = Pathname.new("Gemfile.local")

      expect(local_gemfile).to exist
      expect(local_gemfile.readlink).to eq gemfile
    end

    it "adds Gemfile.local.lock to the .gitignore file" do
      system "touch Gemfile"
      local_gems "--init"

      gitignore = Pathname.new(".gitignore")

      expect(gitignore).to exist
      expect(gitignore.read).to include("Gemfile.local.lock")
    end

    it "outputs a definition for local_gems? if it's not in the Gemfile" do
      system "touch Gemfile"
      expect { local_gems "--init", quiet: false }
        .to output(
          a_string_matching("Add this definition to your Gemfile, to check when configuring gems:")
        ).to_stdout_from_any_process
    end
  end

  describe "exe/local_gems --enable" do
    around :example do |example|
      in_temp_dir(&example)
    end

    it "configures the local Gemfile to be Gemfile.local" do
      local_gems "--enable"

      # NOTE: I a_string_matching gets tripped up on the quotes for these lines, not sure why.
      # Set for your local app (/private/tmp/__local_gems_spec/.bundle/config): "Gemfile.local"
      # Set via BUNDLE_GEMFILE: "/private/tmp/__local_gems_spec/.bundle/config"
      bundle_config_path = Pathname.pwd.join(".bundle/config").to_s
      expect { system "bundle config gemfile" }
        .to output(
          /Set for your local app \(#{bundle_config_path}\): "Gemfile\.local"/
        ).to_stdout_from_any_process
    end
  end

  describe "exe/local_gems --disable" do
    around :example do |example|
      in_temp_dir(&example)
    end

    it "clears the local Gemfile configuration" do
      pending "something is leaving BUNDLE_GEMFILE in the ENV"

      local_gems "--enable"
      local_gems "--disable"

      expect { system "printenv BUNDLE_GEMFILE" }
        .to output("").to_stdout_from_any_process

      # require "pry"; binding.pry
      expect { system "bundle config gemfile" }
        .to output(
          a_string_matching("You have not configured a value for `gemfile`")
        ).to_stdout_from_any_process
    end
  end

  # -- Spec helper methods

  private def in_temp_dir(&block)
    temp_dir = "/tmp/__local_gems_spec"
    mkdir_p(temp_dir)
    chdir(temp_dir) do
      block.yield
    end
  ensure
    rm_r(temp_dir)
  end

  private def local_gems(*args, quiet: true)
    local_gems_cmd = File.expand_path("../exe/local_gems", __dir__)
    quiet ? system_quiet(local_gems_cmd, *args) : system(local_gems_cmd, *args)
  end

  private def system_quiet(*args, **kwargs)
    system(
      *args,
      **kwargs,
      # err: "/dev/null",
      out: "/dev/null",
      exception: true,
    )
  end
end
