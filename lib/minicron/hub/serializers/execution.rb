class Minicron::Hub::App::ExecutionSerializer
  def initialize(executions)
    @executions = executions
  end

  def serialize
    @response = {
      :executions => [],
      :jobs => [],
      :job_execution_outputs => [],
      :hosts => []
    }

    if @executions.respond_to? :each
      @executions.each do |execution|
        do_serialization(execution)
      end
    else
      do_serialization(@executions)
    end

    @response
  end

  def do_serialization(execution)
    new_execution = {}

    # Add all the normal attributes of the execution
    execution.attributes.each do |key, value|
      # Remove _id from keys
      key = key[-3, 3] == '_id' ? key[0..-4] : key

      new_execution[key] = value
    end

    # Set up the job execution output ids array
    new_execution[:job_execution_outputs] = []

    # Add the job to the sideloaded data
    new_job = {}
    execution.job.attributes.each do |key, value|
      # To make our name method in the model work :/
      value = execution.job.name if key == 'name'

      # Remove _id from keys
      key = key[-3, 3] == '_id' ? key[0..-4] : key

      new_job[key] = value
    end

    # Append the new job to the @response
    @response[:jobs].push(new_job)

    # Append the job host to the @response
    @response[:hosts].push(execution.job.host)

    # Add the job execution outputs to the sideloaded data and the ids to
    # the execution
    execution.job_execution_outputs.each do |job_execution_output|
      new_job_execution_output = {}

      job_execution_output.attributes.each do |key, value|
        # Remove _id from keys
        key = key[-3, 3] == '_id' ? key[0..-4] : key
        new_job_execution_output[key] = value
      end

      @response[:job_execution_outputs].push(new_job_execution_output)
      new_execution[:job_execution_outputs].push(job_execution_output.id)
    end

    # Append the new execution to the @response
    @response[:executions].push(new_execution)
  end
end
