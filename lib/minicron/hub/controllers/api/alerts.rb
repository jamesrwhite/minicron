class Minicron::Hub::App
  # Get all alerts
  get '/api/alerts' do
    content_type :json
    alerts = Minicron::Hub::Alert.all
                                 .includes(:schedule, :execution)
                                 .order(:id => :asc)
    Minicron::Hub::AlertSerializer.new(alerts).serialize.to_json
  end

  # Get a single job execution output by it ID
  get '/api/alerts/:id' do
    content_type :json
    alert = Minicron::Hub::Alert.includes(:schedule, :execution)
                                .order(:id => :asc)
                                .find(params[:id])
    Minicron::Hub::AlertSerializer.new(alert).serialize.to_json
  end
end
