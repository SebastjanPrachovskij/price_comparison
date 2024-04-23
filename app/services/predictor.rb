class Predictor
  include HTTParty
  base_uri 'http://localhost:5000'

  def self.predict(series)
    response = post('/predict', body: {series: series}.to_json, headers: { 'Content-Type': 'application/json' })
    response.parsed_response # This returns the JSON response body
  end
end
