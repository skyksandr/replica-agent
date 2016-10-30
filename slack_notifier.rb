require 'net/http'
require 'json'

module Support
  class SlackNotifier
    def notify(text)
      adapter.request(message(text))
    end

    private

    def message(text)
      request = Net::HTTP::Post.new(uri.request_uri)
      params = {text: text}
      request.body = params.to_json
      request
    end

    def adapter
      @adapter ||= begin
        net = Net::HTTP.new(uri.host, uri.port)
        net.use_ssl = true
        net
      end
    end

    def uri
      @uri ||= URI.parse(config["slack_url"])
    end

    def config
      @config ||= YAML.load_file './config.yml'
    end
  end
end
