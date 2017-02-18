class Minicron::Hub::App
  get '/user/profile' do
    erb :'user/profile/index', layout: :'layouts/app'
  end

  post '/user/profile' do
    begin
      new_password = params[:password].length > 0

      # Validate the new password length here before it gets to the model if it's set
      if new_password && params[:password].length < 8
        raise Minicron::AuthError, "Password must be at least 8 characters long"
      end

      # Update their profile
      current_user.name = params[:name]
      current_user.email = params[:email]
      current_user.password = SCrypt::Password.create(params[:password], key_len: 64) if new_password

      current_user.save!
    rescue Exception => e
      flash.now[:error] = e.message
    end

    flash.now[:success] = "Profile updated!"

    erb :'user/profile/index', layout: :'layouts/app'
  end
end
