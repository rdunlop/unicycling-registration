#!/usr/bin/env ruby

# This packages up the code coverage metrics and
# sends them to CodeClimate via the CodeClimate Test Reporter Gem

# from https://github.com/codeclimate/ruby-test-reporter/issues/10
# https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

# Possibly look at:
# http://technology.indiegogo.com/2015/08/how-we-get-coverage-on-parallelized-test-builds/
require "codeclimate-test-reporter"

branch = ENV['CIRCLE_BRANCH']
node_index = ENV['CIRCLE_NODE_INDEX'].to_i
node_total = ENV['CIRCLE_NODE_TOTAL'].to_i
coverage_dir = File.join("coverage")

# Create directory if it doesn't exist
require 'fileutils'
FileUtils.mkdir_p coverage_dir

filename = '.resultset.json'

SimpleCov.coverage_dir(coverage_dir)

# Only run on node0
exit unless node_index.zero?

if node_total > 0
  # Copy coverage results from all nodes to circle artifacts directory
  1.upto(node_total - 1) do |i|
    node = "node#{i}"
    # Modified because circleCI doesn't appear to deal with artifacts in the expected manner
    node_project_dir = `ssh #{node} 'printf $CIRCLE_PROJECT_REPONAME'`
    from = File.join("~/", node_project_dir, 'coverage', filename)
    to = File.join(coverage_dir, "#{i}#{filename}")
    command = "scp #{node}:#{from} #{to}"

    puts "running command: #{command}"
    `#{command}`
  end
end

# Merge coverage results from other nodes
# .resultset.json is a hidden file and thus ignored by the glob
files = Dir.glob(File.join(coverage_dir, "*#{filename}"))
files.each_with_index do |file, i|
  resultset = JSON.load(File.read(file))
  resultset.each do |_command_name, data|
    result = SimpleCov::Result.from_hash(['command', i].join => data)
    SimpleCov::ResultMerger.store_result(result)
  end
end

merged_result = SimpleCov::ResultMerger.merged_result
merged_result.command_name = 'RSpec'

# Format merged result with html
html_formatter = SimpleCov::Formatter::HTMLFormatter.new
html_formatter.format(merged_result)

# Only submit coverage to codeclimate on master branch
exit if branch != 'master'

# Post merged coverage result to codeclimate
codeclimate_formatter = CodeClimate::TestReporter::Formatter.new
codeclimate_formatter.format(merged_result)
