class Minicron::Hub::App
  # Get all schedules
  # TODO: Add offset/limit
  get '/api/schedules' do
    content_type :json
    schedules = Minicron::Hub::Schedule.all.order(:id => :asc)
                                       .includes(:job)

    ScheduleSerializer.new(schedules).serialize.to_json
  end

  # Get a single schedule by it ID
  get '/api/schedules/:id' do
    content_type :json
    schedule = Minicron::Hub::Schedule.includes(:job).find(params[:id])
    ScheduleSerializer.new(schedule).serialize.to_json
  end

  # Create a new schedule
  post '/api/schedules' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Try and save the new schedule
      schedule = Minicron::Hub::Schedule.create(
        :schedule => request_body['schedule']['schedule'],
        :job_id => request_body['schedule']['job']
      )

      schedule.save!

      # Return the new schedule
      ScheduleSerializer.new(schedule).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Update an existing schedule
  put '/api/schedules/:id' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Find the schedule
      schedule = Minicron::Hub::Schedule.includes(:job).find(params[:id])

      # Update the name and schedule
      schedule.schedule = request_body['schedule']['schedule']

      schedule.save!

      # Return the new schedule
      ScheduleSerializer.new(schedule).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Delete an existing schedule
  delete '/api/schedules/:id' do
    content_type :json
    begin
      # Try and delete the schedule
      Minicron::Hub::Schedule.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
