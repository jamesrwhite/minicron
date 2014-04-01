module Minicron
  module Hub
    class JobExecutionOutputSerializer
      def initialize(job_execution_outputs)
        @job_execution_outputs = job_execution_outputs
      end

      def serialize
        @response = {
          :job_execution_outputs => [],
          :executions => []
        }

        if @job_execution_outputs.respond_to? :each
          @job_execution_outputs.each do |job_execution_output|
            do_serialization(job_execution_output)
          end
        else
          do_serialization(@job_execution_outputs)
        end

        @response
      end

      def do_serialization(job_execution_output)
        new_job_execution_output = {}

        # Add all the normal attributes of the job_execution_output
        job_execution_output.attributes.each do |key, value|
          # Remove _id from keys
          key = key[-3, 3] == '_id' ? key[0..-4] : key
          new_job_execution_output[key] = value
        end

        # Add the execution to the sideloaded data
        new_execution = {}
        job_execution_output.execution.attributes.each do |key, value|
          # Remove _id from keys
          key = key[-3, 3] == '_id' ? key[0..-4] : key

          new_execution[key] = value
        end

        # Append the new execution to the @response
        @response[:executions].push(new_execution)

        # Append the new job_execution_output to the @response
        @response[:job_execution_outputs].push(new_job_execution_output)
      end
    end
  end
end
