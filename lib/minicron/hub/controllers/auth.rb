class Minicron::Hub::App
  get '/auth/sign-in' do
    @previous = Minicron::Hub::User.new

    erb :'auth/sign-in', layout: :'layouts/app'
  end

  post '/auth/sign-in' do
    @previous = Minicron::Hub::User.new

    begin
      # Find the user based on their email address
      user = Minicron::Hub::User.where(email: params[:email]).first

      # If we couldn't find the user by email or the password was incorrect
      # raise an error without giving away what was wrong
      if !user || !user.valid_password?(params[:password])
        raise Minicron::AuthError, "Invalid credentials"
      end

      redirect "#{route_prefix}/"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'auth/sign-in', layout: :'layouts/app'
  end

  get '/auth/sign-up' do
    @previous = Minicron::Hub::User.new

    erb :'auth/sign-up', layout: :'layouts/app'
  end

  post '/auth/sign-up' do
    @previous = Minicron::Hub::User.new

    begin
      # Validate the password length here before it gets to the model
      if params[:password].length < 8
        raise Minicron::AuthError, "Password must be at least 8 characters long"
      end

      password = SCrypt::Password.create(params[:password], key_len: 64)

      user = Minicron::Hub::User.create!(
        name: params[:name],
        email: params[:email],
        password: password,
      )

      user.save!

      redirect "#{route_prefix}/"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'auth/sign-up', layout: :'layouts/app'
  end
end
