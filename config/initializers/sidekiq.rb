require 'sidekiq'
require 'sidekiq-cron'
require 'csv'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }

  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file) && Sidekiq.server?
    schedule = YAML.load_file(schedule_file)
    # Read data from CSV and update the job args
    csv_file_path = Rails.root.join('data.csv')
    if File.exist?(csv_file_path)
      csv_data = CSV.read(csv_file_path, headers: true)
      job_args = csv_data.map { |row| row.to_hash }
      schedule['multi_search_job']['args'] = job_args
    end
    Sidekiq::Cron::Job.load_from_hash schedule
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end
