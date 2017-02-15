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

          # Authenticate API requests using API keys
          if api_request?(req.fullpath)
            # Get the API Key from the request
            api_key = req.env["HTTP_X_API_KEY"]

            # Try and find a user that matches the api key
            user = api_key ? Minicron::Hub::User.where(api_key: api_key).first : nil

            if user
              # Add the user to the env so we can use it later
              env[:user] = user
            else
              return [
                401,
                {'Content-Type': 'application/json'},
                ['{"error": "Invalid API credentials"}']
              ]
            end
          # Authenticate the user if the route is protected
          elsif protected?(req.fullpath)
            # Get the user id from the session
            user_id = req.session[:user_id]

            # Try and find a user that matches the user id
            user = user_id ? Minicron::Hub::User.find(req.session[:user_id]) : nil

            if user
              # Add the user to the env so we can use it later
              env[:user] = user
            else
              # If the user has bad data in their session for some reason, remove it
              req.session.delete(:user_id)

              return [
                301,
                {'Location' => "#{Minicron::Transport::Server.get_prefix}/auth/sign-in"},
                []
              ]
            end
          end

          # Call the next middleware in the chain
          status, headers, body = @app.call(env)

          [status, headers, body]
        end

        private

        def protected?(path)
          # Routes we don't need to enforce auth on
          public_routes = ["/auth", "/assets", "/favicon.ico", "/__better_errors"].map do |route|
            "#{Minicron::Transport::Server.get_prefix}#{route}"
          end

          !path.start_with?(*public_routes)
        end

        def api_request?(path)
          path.start_with?("#{Minicron::Transport::Server.get_prefix}/api")
        end
      end
    end
  end
end
