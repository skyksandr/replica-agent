require 'webrick'

module Jobs
  class HookHandler
    KEY = 'secret_key'

    def start
      @server = WEBrick::HTTPServer.new Port: 10080

      @server.mount_proc '/' do |request, _|
        next unless request.request_uri.path == "/#{KEY}"
        handle_hook
      end

      @server.start
    end

    def shutdown
      @server.shutdown
    end

    private
    
    def handle_hook
      notify('handle hook')
    end
  end
end
