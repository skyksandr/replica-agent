require 'webrick'

# Class for New Relic pings to verify that agent works correctly
module Jobs
  class Ping
    def start
      server = WEBrick::HTTPServer.new Port: 10088

      server.mount_proc '/ping' do |_, response|
        response.status = 200
      end

      server.start
    end
  end
end
