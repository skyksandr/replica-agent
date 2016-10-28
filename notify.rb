require 'net/http'
require 'json'

class SlackNotifier
  def initialize(url)
    @url = url
  end

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
    @uri ||= URI.parse(@url)
  end
end
