module Minicron
  module Hub
    module Middleware
      class CacheHeaders
        def initialize(app, options={})
          @app = app
          @options = options
        end

        def call(env)
          # Get an easier to work with request object
          req = Rack::Request.new(env)

          # Call the next middleware in the chain
          status, headers, body = @app.call(env)

          # Prevent caching on non assets
          unless cacheable?(req.fullpath)
            headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
            headers['Pragma'] = 'no-cache'
            headers['Expires'] = '0'
          end

          [status, headers, body]
        end

        private

        def cacheable?(path)
          # Cacheable paths
          cacheable_paths = ["/assets", "/favicon.ico"]

          path.start_with?(*cacheable_paths)
        end
      end
    end
  end
end
