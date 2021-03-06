require 'zookeeper'
require 'json'
require 'uri'


module ZkClient
  ROOT = '/'

  class << self

    def client
      @@client ||= create_client
    end

    def read(path)
      read_node(path)[:data]
    end

    def read_node(path)
      key = process_path(path)
      client.get(path: key)
    end

    def write(path, data)
      key = process_path(path)
      response = client.set(path: key, data: data)
      if !response[:stat].exists
        create(key, data)
      else
        response
      end
    end

    def create(path, data)
      key = process_path(path)
      resp = client.create(path: key, data: data)
    end

    def delete(path)
      key = process_path(path)
      client.delete(path: key)
    end

    def children(path)
      key = process_path(path)
      client.get_children(path: key)[:children]
    end

    def close
      client.close
    end

    def reopen
      @@client = create_client
    end

    def config
      if block_given?
        yield(self)
      end
    end

    def root_path
      @@root_path ||= ROOT
    end

    def root_path=(root)
      @@root_path = root
    end

    def host
      @@host ||= "localhost"
    end

    def host=(host)
      @@host = host
    end

    def port
      @@port ||= 2181
    end

    def port=(port)
      @@port = port.to_i
    end

    def uri
      "#{host}:#{port}"
    end

    def uri=(uri)
      parsed_uri = URI(schemeify(uri))

      @@host      = parsed_uri.host
      @@port      = parsed_uri.port
      @@root_path = parsed_uri.path
    end

    # Backward compatibility
    def root
      root_path
    end

    private

    def create_client
      if defined?(@@client) && @@client.respond_to?(:close)
        @@client.close
      end
      Zookeeper.new(uri)
    end

    def process_path(path)
      path = "/#{path}" unless path.start_with?('/') # We want leading slash
      path = path[0...-1] if path[-1] == '/' # Remove trailing slash
      path = "#{root_path}#{path}" unless path.start_with?(root_path)

      path
    end

    def schemeify(uri)
      if (uri =~ /^http(s)?:\/\/(.)+/) == 0
        uri
      else
        "http://#{uri}"
      end
    end

  end # End class methods
end
