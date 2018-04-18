# frozen_string_literal: true

begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "master"
  gem "arel", github: "rails/arel", branch: "master"
  gem "activerecord-oracle_enhanced-adapter",  github: "rsim/oracle-enhanced", branch: "master"
  gem "minitest"

  platforms :ruby do
    gem "ruby-oci8"
  end
end

require "active_record"
require "minitest/autorun"
require "logger"
require "active_record/connection_adapters/oracle_enhanced_adapter"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# Set Oracle enhanced adapter specific connection parameters
DATABASE_NAME = ENV["DATABASE_NAME"] || "orcl"
DATABASE_HOST = ENV["DATABASE_HOST"]
DATABASE_PORT = ENV["DATABASE_PORT"]
DATABASE_USER = ENV["DATABASE_USER"] || "oracle_enhanced"
DATABASE_PASSWORD = ENV["DATABASE_PASSWORD"] || "oracle_enhanced"
DATABASE_SYS_PASSWORD = ENV["DATABASE_SYS_PASSWORD"] || "admin"

CONNECTION_PARAMS = {
  adapter: "oracle_enhanced",
  database: DATABASE_NAME,
  host: DATABASE_HOST,
  port: DATABASE_PORT,
  username: DATABASE_USER,
  password: DATABASE_PASSWORD
}

ActiveRecord::Base.establish_connection(CONNECTION_PARAMS)

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :dashboards, force: true do |t|
    t.string :dashboard_id
    t.string :name
  end
end

class Dashboard < ActiveRecord::Base
#  self.partial_writes = false
end

class BugTest < Minitest::Test
  def test_partial_writes_false
    dashboard = Dashboard.create!
    assert 1, dashboard.id
  end
end
