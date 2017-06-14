require 'scrypt'

class Minicron::Hub::App
  get '/auth/sign-in' do
    @previous = Minicron::Hub::Model::User.new

    erb :'auth/sign-in', layout: :'layouts/app'
  end

  post '/auth/sign-in' do
    @previous = Minicron::Hub::Model::User.new

    begin
      # Authenticate the user
      user = Minicron::Hub::Model::User.auth(params[:email], params[:password])

      # Write their user id into the session if it existed
      if user
        session[:user_id] = user.id
      else
        raise Minicron::AuthError, "Invalid credentials"
      end

      redirect "#{route_prefix}/"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'auth/sign-in', layout: :'layouts/app'
  end

  post '/auth/sign-out' do
    # Remove the session id from the session
    session.delete(:user_id)

    flash.now[:success] = "Signed Out"

    redirect "#{route_prefix}/auth/sign-in"
  end

  get '/auth/sign-up' do
    @previous = Minicron::Hub::Model::User.new

    erb :'auth/sign-up', layout: :'layouts/app'
  end

  post '/auth/sign-up' do
    @previous = Minicron::Hub::Model::User.new

    begin
      # Validate the password length here before it gets to the model
      if params[:password].length < 8
        raise Minicron::AuthError, "Password must be at least 8 characters long"
      end

      # Hash their password with scrypt
      password = SCrypt::Password.create(params[:password], key_len: 64)

      # Create their account
      user = Minicron::Hub::Model::User.create!(
        name: params[:name],
        email: params[:email],
        password: password,
        api_key: SecureRandom.urlsafe_base64(48)
      )

      # Sign them straight in
      session[:user_id] = user.id

      redirect "#{route_prefix}/"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'auth/sign-up', layout: :'layouts/app'
  end
end
