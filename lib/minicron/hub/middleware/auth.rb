module Minicron
  module Hub
    module Middleware
      class Auth
        def initialize(app, options={})
          @app = app
          @options = options
        end

        def call(env)
          # Get an easier to work with request object
          req = Rack::Request.new(env)

          # Authenticate the user if the route is protected
          if protected?(req.fullpath)
            # Check this user exists in the db
            valid = req.session[:user_id] != nil && Minicron::Hub::User.exists?(req.session[:user_id])

            # If the user has bad data in their session for some reason, remove it
            req.session.delete(:user_id) unless valid

            # If not redirect to the home page
            return [
              301,
              {'Location' => "#{Minicron::Transport::Server.get_prefix}/auth/sign-in"},
              []
            ] unless valid
          end

          # Call the next middleware in the chain
          status, headers, body = @app.call(env)

          [status, headers, body]
        end

        private

        def protected?(path)
          # Routes we don't need to enforce auth on
          public_routes = ["/auth", "/api", "/assets", "/favicon.ico", "/__better_errors"]

          !path.start_with?(*public_routes)
        end
      end
    end
  end
end
