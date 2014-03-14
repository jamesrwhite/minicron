class Minicron::Hub::App::HostSerializer
  def initialize(hosts)
    @hosts = hosts
  end

  def serialize
    @response = {
      :hosts => [],
      :jobs => []
    }

    if @hosts.respond_to? :each
      @hosts.each do |host|
        do_serialization(host)
      end
    else
      do_serialization(@hosts)
    end

    @response
  end

  def do_serialization(host)
    new_host = {}

    # Add all the normal attributes of the host
    host.attributes.each do |key, value|
      new_host[key] = value
    end

    # Set up the job host output ids array
    new_host[:jobs] = []

    # Add the jobs to the sideloaded data and the ids to
    # the host
    host.jobs.each do |job|
      new_job = {}

      job.attributes.each do |key, value|
        # To make our name method in the model work :/
        value = job.name if key == 'name'

        # Remove _id from keys
        key = key[-3, 3] == '_id' ? key[0..-4] : key

        # Append the job
        new_job[key] = value
      end

      @response[:jobs].push(new_job)
      new_host[:jobs].push(job.id)
    end

    # Append the new host to the @responseh
    @response[:hosts].push(new_host)
  end
end
