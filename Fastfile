fastlane_require 'open3'
fastlane_require 'json'

default_platform :ios

platform :ios do
  lane :snapshot_test do |options|
    Dir.chdir("#{ENV['PWD']}") do

      workspace = 'Folio.xcworkspace'
      scheme = 'Folio-Release-Staging'
      system("xcodebuild build-for-testing -workspace #{workspace} -scheme #{scheme} -destination 'generic/platform=iOS Simulator' ENABLE_TESTABILITY=YES")

      only_testing = options[:target_tests] != nil ? "FolioTests/#{options[:target_tests]}" : "FolioTests"

      snapshot_test(workspace, scheme, 'iPhone XS MAX', '12.1', only_testing)
      snapshot_test(workspace, scheme, 'iPhone X', '11.4', only_testing)
      snapshot_test(workspace, scheme, 'iPhone SE', '12.1', only_testing)
      snapshot_test(workspace, scheme, 'iPhone SE', '11.4', only_testing)
      snapshot_test(workspace, scheme, 'iPhone SE', '10.3.1', only_testing)
    end
  end

  def snapshot_test(workspace, scheme, device, os_version, only_testing)
    system("xcodebuild test-without-building -workspace #{workspace} -scheme #{scheme} RECORD_MODE_ENV=true -destination 'name=#{device},OS=#{os_version}' -only-testing:#{only_testing}")
  end

  lane :add_release_tag do
    if !ENV['CI']
      next
    end

    ensure_git_status_clean

    version_number = get_version_number target: 'Folio'
    build_number = get_build_number

    add_git_tag(tag: "#{version_number}-#{build_number}")
    sh('git push --tags')
  end

  desc 'Update dependencies managed by Carthage and CocoaPods'
  lane :update_dependencies do
    if !ENV['CI']
      next
    end

    Dir.chdir("#{ENV['PWD']}") do
      sh 'carthage update --platform ios --configuration Release --cache-builds'
      sh 'bundle exec pod update'

      unless system('git diff --quiet --exit-code')
        system('git add Cartfile.resolved')
        system('git add Podfile.lock')
        commit_push_create_pr(branch_name: "ci/update-dependencies-#{Time.now.to_i}", message: 'Update dependencies managed by Carthage and CocoaPods')
      end
    end
  end

  lane :update_license_list do
    if !ENV['CI']
      next
    end

    github_token = ENV['GITHUB_ACCESS_TOKEN']
    Dir.chdir("#{ENV['PWD']}") do
      sh "Pods/LicensePlist/license-plist --force --output-path Folio/Settings.bundle --github-token #{github_token} --suppress-opening-directory"

      unless system('git diff --quiet --exit-code')
        sh 'git add Folio/Settings.bundle/'
        commit_push_create_pr(branch_name: "ci/update-license-#{Time.now.to_i}", message: 'Update license list')
      end
    end
  end

  lane :update_tools do
    if !ENV['CI']
      next
    end

    Dir.chdir("#{ENV['PWD']}") do
      sh 'bundle update'

      unless system('git diff --quiet --exit-code')
        sh 'git add Gemfile.lock'
        commit_push_create_pr(branch_name: "ci/update-tools-#{Time.now.to_i}", message: 'Update developer tools')
      end
    end
  end

  lane :sync_bitrise_yml do
    if !ENV['CI']
      next
    end

    Dir.chdir("#{ENV['PWD']}") do
      sh "curl -O -H 'Authorization: token #{ENV['BITRISE_ACCESS_TOKEN']}' 'https://api.bitrise.io/v0.1/apps/#{ENV['BITRISE_APP_SLUG']}/bitrise.yml'"

      unless system('git diff --quiet --exit-code')
        sh 'git add bitrise.yml'
        commit_push_create_pr(branch_name: "ci/sync-bitrise_yml-#{Time.now.to_i}", message: 'Sync bitrise.yml')
      end
    end
  end

  def commit_push_create_pr(branch_name: "", message: "")
    github_token = ENV['GITHUB_ACCESS_TOKEN']
    sh "git checkout -b #{branch_name}"
    sh "git commit -m '#{message}'"
    sh 'git push origin HEAD'
    create_pull_request(
      api_token: github_token,
      repo: ENV['FOLIO_APP_REPO'],
      title: message,
      head: branch_name
    )
  end

  lane :screenshots_preview_generator do
    Dir.chdir("#{ENV['PWD']}") do
      sh "./script/screenshots-preview-generator.rb"
    end
  end

  desc 'download dSYMs recompiled on App Store Connect, and upload them to Crashlytics to analyze crashes on released app'
  lane :refresh_dsyms do

    if ENV['CI']
      ENV['FASTLANE_PASSWORD'] = ENV['ITUNES_CONNECT_PASSWORD']
      download_dsyms(
        username: ENV['ITUNES_CONNECT_ID'],
        app_identifier: 'com.folio-sec.folio-app'
      )
      upload_symbols_to_crashlytics(
        api_token: ENV['CRASHLYTICS_API_TOKEN']
      )
    else
      download_dsyms(
        app_identifier: 'com.folio-sec.folio-app'
      )
      upload_symbols_to_crashlytics()
    end
    clean_build_artifacts
  end

  desc 'Run image assets tests'
  lane :image_assets_tests do
    destinations = [
      'name=iPhone 5s,OS=10.3.1',
      'name=iPhone 5s,OS=11.4',
      'name=iPhone SE,OS=10.3.1',
      'name=iPhone SE,OS=11.4',
      'name=iPhone 7,OS=10.3.1',
      'name=iPhone 7,OS=11.4',
      'name=iPhone 7 Plus,OS=10.3.1',
      'name=iPhone 8,OS=11.4',
      'name=iPhone 8 Plus,OS=11.4',
      'name=iPhone X,OS=11.4',
      'name=iPhone Xs,OS=12.2',
    ]
    destinations.each do |destination|
      run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], destination, 'FolioTests/ImageAssetTests')
    end
  end

  desc 'Run Folio.app tests'
  lane :folio_tests do
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone X,OS=11.4', 'FolioTests')
    # run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone SE,OS=11.2', 'FolioTests')
    # run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone SE,OS=10.3.1', 'FolioTests')
  end

  desc 'Run Redux library tests'
  lane :redux_tests do
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone X,OS=11.2', 'ReduxTests')
  end

  desc 'Run NotificationServiceLib library tests'
  lane :notification_service_tests do
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone X,OS=11.2', 'NotificationServiceLibTests')
  end

  desc 'Run Folio.app nightly tests'
  lane :folio_nightly_tests do
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone Xs Max,OS=12.1', 'FolioTests')
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone X,OS=11.4', 'FolioTests')
    run_test(ENV['BITRISE_WORKSPACE'], ENV['BITRISE_SCHEME'], 'name=iPhone SE,OS=10.3.1', 'FolioTests')
  end

  def run_test(workspace, scheme, destination, testcase)
    Dir.chdir("#{ENV['PWD']}") do
      sh "set -o pipefail && xcodebuild -alltargets clean"
      sh "set -o pipefail && xcodebuild test -workspace #{workspace} -scheme #{scheme} -destination '#{destination}' -only-testing:#{testcase} -derivedDataPath DerivedData -enableCodeCoverage YES ENABLE_TESTABILITY=YES | xcpretty"
    end
  end

  class GitHub
    attr_reader :slug
    attr_reader :access_token

    def initialize(owner, repo, access_token)
      @owner = owner
      @repo = repo
      @access_token = access_token
    end

    def upload_file(filepath, tag, branch = 'master')
      raise "A personal access token is required" unless access_token

      response = create_tag(tag, branch)
      pp response
      if response['id']
        upload_release(filepath, response['id'])
      end
    end

    def download_asset(tag)
      raise "A personal access token is required" unless access_token

      response = find_release(tag)
      pp response
      if response['assets']
        asset_id = response['assets'][0]['id']
        Fastlane::Actions::sh "curl -sSfLJO -H 'Accept: application/octet-stream' #{asset_url(asset_id)}"
      end
    end

    def replace_file(filepath, tag)
      raise "A personal access token is required" unless access_token

      response = find_release(tag)
      pp response
      if response['assets']
        asset_id = response['assets'][0]['id']
        Fastlane::Actions::sh "curl -sSfL -X DELETE #{asset_url(asset_id)}"

        upload_release(filepath, response['id'])
      else
        upload_file(filepath, tag)
      end
    end

    private

    def create_tag(tag, branch)
      data = {tag_name: tag, target_commitish: branch, name: tag, body: '', draft: false, prerelease: false}.to_json
      url = "https://api.github.com/repos/#{slug}/releases?access_token=#{access_token}"

      out, status = Open3.capture2(*['curl', '-sSL', '-d', "#{data}", "#{url}"])
      JSON.parse(out)
    end

    def upload_release(filepath, release_id)
      filename = File.basename(filepath)
      url = "https://uploads.github.com/repos/#{slug}/releases/#{release_id}/assets?name=#{filename}&access_token=#{access_token}"

      Fastlane::Actions::sh %[curl -sSL -X POST "#{url}" -H "Content-Type: application/gzip" --data-binary @"#{filepath}"]
    end

    def find_release(hash)
      url = "https://api.github.com/repos/#{slug}/releases/tags/#{hash}?access_token=#{access_token}"

      out, status = Open3.capture2(*['curl', '-sSL', "#{url}"])
      JSON.parse(out)
    end

    def slug
      "#{@owner}/#{@repo}"
    end

    def asset_url(asset_id)
      "https://api.github.com/repos/#{slug}/releases/assets/#{asset_id}?access_token=#{access_token}"
    end
  end

  github = GitHub.new(ENV['GITHUB_OWNER'], ENV['GITHUB_CACHE_REPO'], ENV['GITHUB_ACCESS_TOKEN'])

  desc 'Archive build dependencies and upload it to GitHub Releases'
  lane :upload_build_cache do
    Dir.chdir("#{ENV['PWD']}") do
      archive_build_dependencies
      github.upload_file(build_cache_file, deps_hash)
      clean_build_cache
    end
  end

  desc 'Download build dependencies and expand it'
  lane :download_build_cache do
    Dir.chdir("#{ENV['PWD']}") do
      github.download_asset(deps_hash)
      system "tar xf #{build_cache_file}"
      clean_build_cache
    end
  end

  desc 'Overwrite the　existing build cache with the latest'
  lane :renew_build_cache do
    Dir.chdir("#{ENV['PWD']}") do
      archive_build_dependencies
      github.replace_file(build_cache_file, deps_hash)
      clean_build_cache
    end
  end

  def archive_build_dependencies
    sh "tar czf #{build_cache_file} --exclude Pods.build --exclude XCBuildData Carthage/Build/ Pods/"
  end

  def build_cache_file
    File.expand_path('./deps.tar.gz')
  end

  def clean_build_cache
    system "rm -f #{build_cache_file}"
  end

  def deps_hash
    %x[cat Cartfile.resolved Podfile.lock | perl -le 'use Digest::SHA qw(sha256_hex); print sha256_hex(<>);'].strip
  end
end
