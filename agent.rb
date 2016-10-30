require 'yaml'
require 'forwardable'
require 'time'
require_relative 'slack_notifier'

class Agent
  extend Forwardable

  def initialize
    @threads = []

    Dir[File.join(File.dirname(__FILE__), 'jobs', '*.rb')].each do |file|
      require file
    end
  end

  def start  
    jobs = ::Jobs.constants.select { |c| Jobs.const_get(c).is_a? Class }
    jobs.map! { |c| Jobs.const_get(c) }
    jobs.each do |job|
      p "Starting #{job.name}"
      @threads << Thread.new do
        job.new.start      
      end
    end

    @threads.each &:join
  end

  def shutdown
    p 'Exiting...'
    @threads.each do |thread|
      Thread.kill(thread)
    end
  end
end

def notify(text)
  @notifier ||= Support::SlackNotifier.new
  @notifier.notify(text)
end

# Start agent 
agent = Agent.new
trap 'INT' do agent.shutdown end
agent.start
