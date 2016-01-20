require 'json'

module ZkCache

  class << self

    def cache(key, value)
      path = _process_path(key)
      _cache[path] = value
    end

    def read(key)
      path = _process_path(key)
      _cache[path]
    end

    def load_cache
      _load_cache(ZkClient.root_path)
      self.to_s
    end

    def destroy_cache
      @@cache = {}
    end

    def to_s
      _cache.to_json
    end

    def root_path
      ZkClient.root_path
    end

    def all
      _cache
    end

    private

    def _cache
      @@cache ||= {}
    end

    def _process_path(path)
      path = "/#{path}" unless path.start_with?('/') # We want leading slash
      path = path[0...-1] if path[-1] == '/' # Remove trailing slash
      path = "#{root_path}#{path}" unless path.start_with?(root_path)

      path
    end

    def _load_cache(path)
      val = ZkClient.read(path)
      cache(path, val)

      children = ZkClient.children(path)
      if children && children.any?
        children.each do |child|
          _load_cache("#{path}/#{child}")
        end
      end
    end

  end

end

