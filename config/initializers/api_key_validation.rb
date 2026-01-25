# config/initializers/api_key_validation.rb
# Validate that required API keys are present at startup

Rails.application.config.after_initialize do
  required_keys = {
    "YOUTUBE_API_KEY" => "YouTube Data API v3",
    "LASTFM_API_KEY" => "Last.fm API",
    "GENIUS_API_KEY" => "Genius API"
  }

  missing_keys = []

  required_keys.each do |key, service|
    if ENV[key].blank?
      missing_keys << "#{key} (#{service})"
    end
  end

  if missing_keys.any?
    error_message = <<~ERROR

      ⚠️  MISSING REQUIRED API KEYS ⚠️

      The following API keys are required but not configured:
      #{missing_keys.map { |k| "  - #{k}" }.join("\n")}

      Please add these keys to your .env file or environment variables.
      See README.md for instructions on obtaining API keys.

    ERROR

    if Rails.env.production?
      # In production, fail hard - the app cannot function without API keys
      raise error_message
    else
      # In development/test, warn but allow the app to start
      Rails.logger.warn error_message
      warn error_message
    end
  else
    Rails.logger.info "✓ All required API keys are configured"
  end
end
