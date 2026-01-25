# config/initializers/security_headers.rb
# Add security headers to all responses

Rails.application.config.action_dispatch.default_headers.merge!(
  {
    # Prevent clickjacking attacks (redundant with CSP frame-ancestors, but good defense in depth)
    "X-Frame-Options" => "DENY",

    # Prevent MIME type sniffing
    "X-Content-Type-Options" => "nosniff",

    # Enable XSS protection in legacy browsers (modern browsers use CSP)
    "X-XSS-Protection" => "1; mode=block",

    # Control referrer information sent with requests
    "Referrer-Policy" => "strict-origin-when-cross-origin",

    # Restrict browser features and APIs
    "Permissions-Policy" => "geolocation=(), microphone=(), camera=(), payment=()",

    # Force HTTPS (only in production)
    # "Strict-Transport-Security" is set in production.rb
  }
)

# Add HSTS header in production environment
Rails.application.config.to_prepare do
  if Rails.env.production?
    Rails.application.config.action_dispatch.default_headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
  end
end
