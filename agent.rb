require 'yaml'
require 'forwardable'
require 'time'
require_relative 'notify'

class Agent
  extend Forwardable

  def initialize
    p replication_lag
  end

  private

  def replication_lag
    str_time = %x(docker exec #{config["container_name"]} psql -U #{config["db_user"]} -A -t -c "select now() - pg_last_xact_replay_timestamp();")
    lag_in_secods = Time.parse(str_time, beginning_of_the_day) - beginning_of_the_day
  end

  def beginning_of_the_day
    current_time = Time.new
    Time.parse "#{current_time.year}-#{current_time.month}-#{current_time.day}"
  end

  def notifier
    @notifier ||= SlackNotifier.new(config["slack_url"])
  end

  def config
    config ||= YAML.load_file './config.yml'
  end

  def_delegators :notifier, :notify
end

Agent.new
# notifier.notify('Hello')
