require 'minicron/transport/ssh'

class Minicron::Hub::App
  get '/hosts' do
    # Look up all the hosts
    @hosts = Minicron::Hub::Host.all.order(:created_at => :desc)
                                .includes(:jobs)

    erb :'hosts/index', :layout => :'layouts/app'
  end

  get '/host/:id' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(:jobs).find(params[:id])

    erb :'hosts/show', :layout => :'layouts/app'
  end

  get '/hosts/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Host.new

    erb :'hosts/new', :layout => :'layouts/app'
  end

  post '/hosts/new' do
    begin
      # Try and save the new host
      host = Minicron::Hub::Host.create!(
        :name => params[:name],
        :fqdn => params[:fqdn],
        :user => params[:user],
        :host => params[:host],
        :port => params[:port]
      )

      # Generate a new SSH key - TODO: add passphrase
      key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

      # And finally we store the public key in the db with the host for convenience
      host.public_key = key.ssh_public_key
      host.save!

      # Redirect to the new host
      redirect "#{route_prefix}/host/#{host.id}"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'hosts/new', :layout => :'layouts/app'
  end

  get '/host/:id/edit' do
    # Find the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/edit', :layout => :'layouts/app'
  end

  post '/host/:id/edit' do
    # Find the host
    @host = Minicron::Hub::Host.find(params[:id])

    begin
      # Update its data
      @host.name = params[:name]
      @host.fqdn = params[:fqdn]
      @host.user = params[:user]
      @host.host = params[:host]
      @host.port = params[:port]

      @host.save!

      # Redirect to the updated host
      redirect "#{route_prefix}/host/#{@host.id}"
    rescue Exception => e
      @host.restore_attributes
      flash.now[:error] = e.message
      erb :'hosts/edit', :layout => :'layouts/app'
    end
  end

  get '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/delete', :layout => :'layouts/app'
  end

  post '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(:jobs => :schedules).find(params[:id])

    begin
      Minicron::Hub::Host.transaction do
        # Try and delete the host
        Minicron::Hub::Host.destroy(params[:id])

        unless params[:force]
          # Get an ssh instance and open a connection
          ssh = Minicron::Transport::SSH.new(
            :user => @host.user,
            :host => @host.host,
            :port => @host.port,
            :private_key => "~/.ssh/minicron_host_#{@host.id}_rsa"
          )

          # Get an instance of the cron class
          cron = Minicron::Cron.new(ssh)

          # Update the crontab
          cron.update_crontab(nil)

          # Tidy up
          ssh.close

          # Delete the pub/priv key pair
          private_key_path = File.expand_path("~/.ssh/minicron_host_#{@host.id}_rsa")
          public_key_path = File.expand_path("~/.ssh/minicron_host_#{@host.id}_rsa.pub")
          File.delete(private_key_path)
          File.delete(public_key_path)
        end

        redirect "#{route_prefix}/hosts"
      end
    rescue Exception => e
      flash.now[:error] =  "<h4>Error</h4>
                            <p>#{e.message}</p>
                            <p>You can force delete the host without connecting to the host</p>"
      erb :'hosts/delete', :layout => :'layouts/app'
    end
  end

  get '/host/:id/test' do
    # Get the host
    @host = Minicron::Hub::Host.find(params[:id])

    begin
      # Set up the ssh instance
      ssh = Minicron::Transport::SSH.new(
        :user => @host.user,
        :host => @host.host,
        :port => @host.port,
        :private_key => "~/.ssh/minicron_host_#{@host.id}_rsa"
      )

      # Get an instance of the cron class
      cron = Minicron::Cron.new(ssh)

      # Test the SSH connection
      @test = cron.get_host_permissions

      # Tidy up
      ssh.close
    rescue Exception => e
      flash.now[:error] = e.message
    end

    erb :'hosts/test', :layout => :'layouts/app'
  end

  get '/host/:id/import' do
    begin
      # Get the host we want to parse the jobs from
      host = Minicron::Hub::Host.find(params[:id])

      # Create an SSH connection
      ssh = Minicron::Transport::SSH.new(
        :user => host.user,
        :host => host.host,
        :port => host.port,
        :private_key => "~/.ssh/minicron_host_#{host.id}_rsa"
      )

      cron = Minicron::Cron.new(ssh)

      # Get the jobs
      crontab_jobs = cron.crontab_jobs(host.name)

      crontab_jobs.each do |cjob|
        # Create the new job...
        job = Minicron::Hub::Job.create!(
          :job_hash => Minicron::Transport.get_job_hash(cjob[:command], host.fqdn),
          :name     => cjob[:name],
          :command  => cjob[:command],
          :host_id  => host.id
        )

        # ... and save it
        job.save!

        # Handle the schedule now
        job_schedule = cjob[:schedule]

        # First we need to check a schedule like this doesn't already exist
        exists = Minicron::Hub::Schedule.exists?(
          :minute           => job_schedule[:minute].nil?           ? nil : job_schedule[:minute],
          :hour             => job_schedule[:hour].nil?             ? nil : job_schedule[:hour],
          :day_of_the_month => job_schedule[:day_of_the_month].nil? ? nil : job_schedule[:day_of_the_month],
          :month            => job_schedule[:month].nil?            ? nil : job_schedule[:month],
          :day_of_the_week  => job_schedule[:day_of_the_week].nil?  ? nil : job_schedule[:day_of_the_week],
          :special          => job_schedule[:special].nil?          ? nil : job_schedule[:special],
          :job_id           => job.id
        )

        if exists
          raise Minicron::ValidationError, 'That schedule already exists for this job'
        end

        Minicron::Hub::Schedule.transaction do
          # Create the new schedule
          schedule = Minicron::Hub::Schedule.create(
            :minute           => job_schedule[:minute].nil?           ? nil : job_schedule[:minute],
            :hour             => job_schedule[:hour].nil?             ? nil : job_schedule[:hour],
            :day_of_the_month => job_schedule[:day_of_the_month].nil? ? nil : job_schedule[:day_of_the_month],
            :month            => job_schedule[:month].nil?            ? nil : job_schedule[:month],
            :day_of_the_week  => job_schedule[:day_of_the_week].nil?  ? nil : job_schedule[:day_of_the_week],
            :special          => job_schedule[:special].nil?          ? nil : job_schedule[:special],
            :job_id           => job.id
          )

          # Save the schedule before looking up the hosts jobs => schedules so the change is there
          schedule.save!
        end
      end

      host = Minicron::Hub::Host.includes(:jobs => :schedules).find(host.id)

      # Update the crontab
      cron.update_crontab(host)

      # Tidy up
      ssh.close

      # Reload the page
      redirect "#{route_prefix}/host/#{host.id}"
    rescue Exception => e
      @host = host
      @previous = params
      flash.now[:error] = e.message
      erb :'hosts/show', :layout => :'layouts/app'
    end
  end
end
