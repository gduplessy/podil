# config/initializers/rack_attack.rb

class Rack::Attack
  # Throttle general requests by IP (300 req/5 minutes)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets") # Don't throttle asset requests
  end

  # Throttle search requests more aggressively (10 req/minute)
  throttle("search/ip", limit: 10, period: 1.minute) do |req|
    if req.path == "/search/results" && req.get?
      req.ip
    end
  end

  # Throttle POST requests to prevent form spam (30 req/minute)
  throttle("post/ip", limit: 30, period: 1.minute) do |req|
    if req.post?
      req.ip
    end
  end

  # Allow localhost through for development
  Rack::Attack.safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # Block suspicious requests (SQL injection attempts, etc.)
  blocklist("block-bad-requests") do |req|
    # Block requests with SQL injection patterns
    req.query_string.to_s.match(/(\bunion\b.*\bselect\b|\bselect\b.*\bfrom\b)/i) ||
    # Block requests with script injection patterns
    req.query_string.to_s.match(/<script|javascript:|onerror=/i) ||
    # Block requests with path traversal attempts
    req.query_string.to_s.match(/\.\.\/|\.\.\\/)
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    [
      429,
      {
        "Content-Type" => "text/html",
        "Retry-After" => retry_after.to_s
      },
      [File.read(Rails.public_path.join("429.html"))]
    ]
  end

  # Log blocked and throttled requests
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled #{req.ip} on #{req.path} (limit: #{payload[:limit]}, period: #{payload[:period]})"
  end

  ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Blocked #{req.ip} on #{req.path} (reason: suspicious request)"
  end
end
