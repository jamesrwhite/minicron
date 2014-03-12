class Minicron::Hub::App::JobSerializer
  def initialize(jobs)
    @jobs = jobs
  end

  def serialize
    @response = {
      :jobs => [],
      :hosts => [],
      :executions => []
    }

    if @jobs.respond_to? :each
      @jobs.each do |job|
        do_serialization(job)
      end
    else
      do_serialization(@jobs)
    end

    @response
  end

  def do_serialization(job)
    new_job = {}

    # Add all the normal attributes of the job
    job.attributes.each do |key, value|
      # To make our name method in the model work :/
      value = job.name if key == 'name'

      # Remove _id from keys
      key = key[-3, 3] == '_id' ? key[0..-4] : key

      new_job[key] = value
    end

    # Set up the execution ids array
    new_job[:executions] = []

    # Add the host to the sideloaded data
    new_host = {}
    job.host.attributes.each do |key, value|
      # To make our name method in the model work :/
      value = job.host.name if key == 'name'

      # Remove _id from keys
      key = key[-3, 3] == '_id' ? key[0..-4] : key

      new_host[key] = value
    end

    # Append the new host to the @response
    @response[:hosts].push(new_host)

    # Add the executions to the sideloaded data and the ids to
    # the job
    job.executions.each do |execution|
      new_execution = {}

      execution.attributes.each do |key, value|
        # Remove _id from keys
        key = key[-3, 3] == '_id' ? key[0..-4] : key

        new_execution[key] = value
      end

      @response[:executions].push(new_execution)
      new_job[:executions].push(execution.id)
    end

    # Append the new job to the @responseh
    @response[:jobs].push(new_job)
  end
end
