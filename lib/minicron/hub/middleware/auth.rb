module Minicron
  module Hub
    module Middleware
      class Auth
        # Routes we don't need to enforce auth on
        public_routes = ["/auth", "/css", "/js", "/fonts", "/__better_errors"]

        def initialize(app, options={})
          @app = app
          @options = options
        end

        def call(env)
          # Get an easier to work with request object
          req = Rack::Request.new(env)

          # Authenticate the user if the route is protected
          if protected?(req.fullpath)
            # If we have a user and password in a POST request try and auth
            if req.post? && req.params["email"] && req.params["password"]
              # Authenticate the user
              user = Minicron::Hub::User.auth(req.params["email"], req.params["password"])

              # Write their user id into the session if it existed
              if user
                req.session[:user_id] = user.id
              end
            end
          end

          # Call the next middleware in the chain
          status, headers, body = @app.call(env)

          [status, headers, body]
        end

        private

        def protected?(path)
          !path.start_with?(*@public_routes)
        end
      end
    end
  end
end
