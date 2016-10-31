require 'webrick'

module Jobs
  class HookHandler
    def start
      @server = WEBrick::HTTPServer.new Port: 10080

      @server.mount_proc '/' do |request, _|
        next unless request.request_uri.path == "/#{config['hook_key']}"
        next unless hook_valid?(request.body)
        handle_hook
      end

      @server.start
    end

    def shutdown
      @server.shutdown
    end

    private
    
    def handle_hook
      notify('New image pushed to Docker Hub. Pulling...')
      %x( docker pull #{config['image_name']}:#{config['image_tag']} )
      notify('Deploying latest backup to staging db')
      notify('Deploying app container')
    end

    def hook_valid?(req_body)
      req_hash = JSON.parse(req_body)
      req_hash.dig('push_data', 'tag') == config['imgage_tag']
    end
  end
end
