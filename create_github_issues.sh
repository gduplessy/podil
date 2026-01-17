#!/bin/bash
# Script to create all GitHub issues for Podil implementation plan
# Usage: bash create_github_issues.sh

set -e

echo "🚀 Creating GitHub issues for Podil implementation plan..."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"
echo ""

# Function to create a label if it doesn't exist
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"

    # Check if label exists
    if gh label list | grep -q "^${name}"; then
        echo "  ✓ Label exists: $name"
    else
        echo "  Creating label: $name"
        gh label create "$name" --color "$color" --description "$description" || echo "  ⚠️  Failed to create label"
    fi
}

# Function to create an issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    echo "Creating: $title"
    gh issue create \
        --title "$title" \
        --body "$body" \
        --label "$labels" || echo "  ⚠️  Failed to create issue (may already exist)"
}

echo "🏷️  Creating GitHub labels..."
echo ""

# Priority labels
echo "Priority labels:"
create_label "priority: P0 - critical" "d73a4a" "Blocks production deploy"
create_label "priority: P1 - high" "ff6b35" "Ship within 1 week"
create_label "priority: P2 - medium" "fbca04" "Ship within 2-4 weeks"
create_label "priority: P3 - low" "0e8a16" "Nice to have"

echo ""
echo "Type labels:"
# Type labels
create_label "type: security" "b60205" "Security vulnerability"
create_label "type: seo" "5319e7" "SEO improvement"
create_label "type: testing" "1d76db" "Test coverage"
create_label "type: tech-debt" "d4c5f9" "Technical debt"
create_label "type: performance" "bfd4f2" "Performance improvement"

echo ""
echo "Size labels:"
# Size labels
create_label "size: XS (< 1hr)" "c2e0c6" "Extra small effort"
create_label "size: S (1-2hrs)" "bfe5bf" "Small effort"
create_label "size: M (2-4hrs)" "a8dba8" "Medium effort"
create_label "size: L (4-8hrs)" "79bd9a" "Large effort"
create_label "size: XL (> 8hrs)" "3b8686" "Extra large effort"

echo ""
echo "✅ All labels created/verified!"
echo ""

echo "📋 Creating P0 (Critical) issues..."
echo ""

# SECURITY-001
create_issue \
    "[SECURITY-001] Remove XSS vulnerability via raw() helper" \
    "## Problem
Critical XSS vulnerability in \`app/views/search/results.html.erb:51\` using \`raw()\` helper.

## Impact
- Session hijacking
- Account takeover
- Data exfiltration

## Fix
Replace raw() with safe SVG partial

## Files to Change
- \`app/views/search/results.html.erb\`
- \`app/views/shared/_music_service_icon.html.erb\` (create)
- \`app/controllers/search_controller.rb\`

## Acceptance Criteria
- [ ] No usage of \`raw()\` helper in views
- [ ] SVG icons render correctly
- [ ] Brakeman scan shows no XSS warnings
- [ ] Tests pass

## Reference
See \`security_check.md\` SEC-001 for detailed fix

## Estimate
1-2 hours

## CVSS Score
8.2 (Critical)" \
    "priority: P0 - critical,type: security,size: S (1-2hrs)"

# SECURITY-002
create_issue \
    "[SECURITY-002] Enable Content Security Policy" \
    "## Problem
Content Security Policy completely disabled in \`config/initializers/content_security_policy.rb\`

## Impact
- No defense against XSS attacks
- Vulnerable to clickjacking
- No protection from malicious scripts

## Fix
Enable and configure CSP with proper directives

## Dependencies
⚠️ Depends on SECURITY-005 (inline JS removal)

## Files to Change
- \`config/initializers/content_security_policy.rb\`
- \`app/controllers/csp_reports_controller.rb\` (create)
- \`config/routes.rb\`

## Acceptance Criteria
- [ ] CSP headers present in HTTP response
- [ ] YouTube embeds still work
- [ ] No inline scripts blocked
- [ ] CSP violation reports logged
- [ ] Tests pass

## Testing
\`\`\`bash
curl -I http://localhost:3000 | grep -i content-security-policy
\`\`\`

## Reference
See \`security_check.md\` SEC-002

## Estimate
2-4 hours

## CVSS Score
7.8 (Critical)" \
    "priority: P0 - critical,type: security,size: M (2-4hrs)"

# SECURITY-003
create_issue \
    "[SECURITY-003] Add rate limiting with Rack::Attack" \
    "## Problem
No rate limiting on search endpoint. Vulnerable to DoS and API quota exhaustion.

## Impact
- Application downtime
- \$\$ Cost overruns from API abuse
- IP bans from external APIs

## Fix
Install and configure Rack::Attack gem

## Files to Change
- \`Gemfile\`
- \`config/initializers/rack_attack.rb\` (create)
- \`config/application.rb\`
- \`public/429.html\` (create)

## Acceptance Criteria
- [ ] Rate limit: 10 searches/minute per IP
- [ ] Rate limit: 300 requests/5min per IP (general)
- [ ] 429 error page displays correctly
- [ ] Localhost bypasses rate limit
- [ ] Tests verify rate limiting works

## Testing
\`\`\`bash
for i in {1..15}; do
  curl 'http://localhost:3000/search/results?q=test'
  sleep 0.5
done
# First 10 should succeed, 11-15 should get 429
\`\`\`

## Reference
See \`security_check.md\` SEC-003

## Estimate
1-2 hours

## CVSS Score
7.5 (Critical)" \
    "priority: P0 - critical,type: security,size: S (1-2hrs)"

# SECURITY-004
create_issue \
    "[SECURITY-004] Add input validation on query parameter" \
    "## Problem
No validation on search query parameter in \`SearchController#results\`

## Impact
- XSS attacks
- Application crashes from nil/empty queries
- API abuse from extremely long strings

## Fix
Add comprehensive input validation

## Files to Change
- \`app/controllers/search_controller.rb\`

## Acceptance Criteria
- [ ] Blank queries return error message
- [ ] Queries > 200 chars rejected
- [ ] Special characters (\`<>\"'\`) rejected
- [ ] Query sanitized before API calls
- [ ] User-friendly error messages
- [ ] Tests cover all edge cases

## Testing
\`\`\`bash
# Test blank query
curl 'http://localhost:3000/search/results'

# Test XSS
curl 'http://localhost:3000/search/results?q=<script>alert(1)</script>'

# Test long query
curl \"http://localhost:3000/search/results?q=\$(python3 -c \"print('A'*300)\")\"
\`\`\`

## Reference
See \`security_check.md\` SEC-004

## Estimate
1-2 hours

## CVSS Score
6.8 (High)" \
    "priority: P0 - critical,type: security,size: S (1-2hrs)"

# SECURITY-005
create_issue \
    "[SECURITY-005] Remove inline JavaScript from views" \
    "## Problem
Inline JavaScript in \`app/views/search/results.html.erb:15-19\` violates CSP

## Impact
- Blocks CSP implementation
- Potential XSS vector

## Fix
Move to Stimulus controller or use Turbo link

## Blocks
⚠️ Blocks SECURITY-002 (CSP implementation)

## Files to Change
- \`app/views/search/results.html.erb\`
- \`app/javascript/controllers/alert_controller.js\` (option 1)

## Acceptance Criteria
- [ ] No inline \`<script>\` tags in views
- [ ] Alert close button still works
- [ ] CSP allows the solution
- [ ] Tests pass

## Reference
See \`security_check.md\` SEC-005

## Estimate
< 1 hour

## CVSS Score
6.5 (High)" \
    "priority: P0 - critical,type: security,size: XS (< 1hr)"

# SEO-001
create_issue \
    "[SEO-001] Add meta descriptions to all pages" \
    "## Problem
No meta descriptions on any pages. 0% SERP optimization.

## Impact
- 0-30% lower click-through rates
- Google writes poor quality descriptions
- Lost keyword targeting opportunity

## Fix
Add meta description tags with content_for pattern

## Files to Change
- \`app/views/layouts/application.html.erb\`
- \`app/views/search/index.html.erb\`
- \`app/views/search/results.html.erb\`

## Acceptance Criteria
- [ ] Default meta description in layout
- [ ] Homepage has specific description (150-160 chars)
- [ ] Results page has dynamic description with song/artist
- [ ] Meta tags validate in HTML validator
- [ ] Lighthouse SEO score improves

## Testing
\`\`\`bash
curl http://localhost:3000 | grep 'meta name=\"description\"'
\`\`\`

## Reference
See \`seo-audit.md\` section 2.1

## Estimate
< 1 hour" \
    "priority: P0 - critical,type: seo,size: XS (< 1hr)"

# SEO-002
create_issue \
    "[SEO-002] Generate and configure sitemap.xml" \
    "## Problem
No sitemap.xml exists. Search engines can't discover pages efficiently.

## Impact
- Slower indexing
- Search engines may miss pages
- No crawl priority control

## Fix
Install sitemap_generator gem and configure

## Files to Change
- \`Gemfile\`
- \`config/sitemap.rb\` (create)
- \`.gitignore\`
- \`public/robots.txt\` (update in SEO-004)

## Acceptance Criteria
- [ ] sitemap_generator gem installed
- [ ] Sitemap generates successfully
- [ ] Sitemap includes homepage and search page
- [ ] Sitemap validates in Google Search Console

## Commands
\`\`\`bash
bundle exec rake sitemap:refresh
gunzip -c public/sitemap.xml.gz | head -20
\`\`\`

## Reference
See \`seo-audit.md\` section 1.2

## Estimate
1-2 hours" \
    "priority: P0 - critical,type: seo,size: S (1-2hrs)"

# SEO-003
create_issue \
    "[SEO-003] Add structured data (Schema.org)" \
    "## Problem
No structured data markup. Missing rich snippets and music carousels in search results.

## Impact
- No rich snippets
- Lost traffic from music-specific features
- Competitors with schema outrank us

## Fix
Add MusicRecording, WebSite, and Breadcrumb schemas

## Files to Change
- \`app/views/search/results.html.erb\`
- \`app/views/search/index.html.erb\`

## Acceptance Criteria
- [ ] MusicRecording schema on results page
- [ ] WebSite + SearchAction schema on homepage
- [ ] Breadcrumb schema on results page
- [ ] Zero errors in Google Rich Results Test
- [ ] Schema validates on schema.org validator

## Testing
- https://search.google.com/test/rich-results
- https://validator.schema.org/

## Reference
See \`seo-audit.md\` section 3.1

## Estimate
2-4 hours" \
    "priority: P0 - critical,type: seo,size: M (2-4hrs)"

echo ""
echo "📋 Creating P1 (High) issues..."
echo ""

# SECURITY-006
create_issue \
    "[SECURITY-006] Add API key validation at startup" \
    "## Problem
No validation that required API keys are set. App crashes with confusing errors.

## Impact
- Production crashes
- Failed deployments
- Confusing error messages

## Fix
Add initializer to validate API keys at startup

## Files to Change
- \`config/initializers/api_keys.rb\` (create)
- \`app/services/youtube_service.rb\`
- \`app/services/lastfm_service.rb\`
- \`app/services/genius_service.rb\`

## Acceptance Criteria
- [ ] App fails to start if keys missing (production)
- [ ] Warning shown in development if keys missing
- [ ] Clear error messages indicate which keys are missing
- [ ] Tests cover missing key scenarios

## Reference
See \`security_check.md\` SEC-006

## Estimate
< 1 hour

## CVSS Score
6.2 (High)" \
    "priority: P1 - high,type: security,size: XS (< 1hr)"

# SECURITY-007
create_issue \
    "[SECURITY-007] Change search forms to POST method" \
    "## Problem
Search forms use GET method. Search queries leak via browser history and referrer headers.

## Impact
- Privacy leak via browser history
- Referrer header leakage
- No CSRF protection

## Fix
Change forms to POST method with CSRF tokens

## Files to Change
- \`app/views/search/index.html.erb\`
- \`app/views/search/results.html.erb\`
- \`config/routes.rb\`

## Acceptance Criteria
- [ ] Forms use POST method
- [ ] CSRF tokens included automatically
- [ ] Search queries not in browser history
- [ ] Tests updated for POST requests

## Reference
See \`security_check.md\` SEC-007

## Estimate
< 1 hour

## CVSS Score
5.5 (Medium)" \
    "priority: P1 - high,type: security,size: XS (< 1hr)"

# SECURITY-008
create_issue \
    "[SECURITY-008] Add security headers" \
    "## Problem
Missing important security headers (X-Frame-Options, X-Content-Type-Options, etc.)

## Impact
- Clickjacking attacks
- MIME sniffing attacks
- Information leakage

## Fix
Configure security headers in initializer

## Files to Change
- \`config/initializers/security_headers.rb\` (create)

## Acceptance Criteria
- [ ] X-Frame-Options: DENY
- [ ] X-Content-Type-Options: nosniff
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] Permissions-Policy set
- [ ] HSTS enabled in production
- [ ] SecurityHeaders.com score: A+

## Testing
\`\`\`bash
curl -I http://localhost:3000 | grep -E 'X-Frame|X-Content'
\`\`\`

Visit: https://securityheaders.com/

## Reference
See \`security_check.md\` SEC-008

## Estimate
< 1 hour

## CVSS Score
5.3 (Medium)" \
    "priority: P1 - high,type: security,size: XS (< 1hr)"

# SECURITY-009
create_issue \
    "[SECURITY-009] Configure API request timeouts" \
    "## Problem
HTTParty requests have no timeout. Hanging APIs block app indefinitely.

## Impact
- Resource exhaustion
- DoS via slow APIs
- Poor UX (page never loads)

## Fix
Add timeout configuration to all services with retry logic

## Files to Change
- \`app/services/youtube_service.rb\`
- \`app/services/lastfm_service.rb\`
- \`app/services/genius_service.rb\`
- \`app/controllers/search_controller.rb\`

## Acceptance Criteria
- [ ] All services have 5s total timeout
- [ ] 2s connection timeout, 3s read timeout
- [ ] 3 retries for transient failures
- [ ] Controller handles timeout exceptions gracefully
- [ ] Tests cover timeout scenarios

## Reference
See \`security_check.md\` SEC-009

## Estimate
1-2 hours

## CVSS Score
5.0 (Medium)" \
    "priority: P1 - high,type: security,size: S (1-2hrs)"

# SECURITY-010
create_issue \
    "[SECURITY-010] URL-encode user input in purchase links" \
    "## Problem
Song titles not URL-encoded in purchase links. Special characters break URLs.

## Impact
- Broken links
- Potential open redirect
- Poor UX

## Fix
Use ERB::Util.url_encode for all URL parameters

## Files to Change
- \`app/controllers/search_controller.rb\`

## Acceptance Criteria
- [ ] All song titles URL-encoded in purchase links
- [ ] Special characters (&?#=) handled correctly
- [ ] Links work for songs with special chars
- [ ] Tests cover URL encoding

## Reference
See \`security_check.md\` SEC-010

## Estimate
< 1 hour

## CVSS Score
4.8 (Medium)" \
    "priority: P1 - high,type: security,size: XS (< 1hr)"

# SEO-004 through SEO-011
create_issue \
    "[SEO-004] Update robots.txt with proper directives" \
    "## Problem
robots.txt is empty. No crawler guidance.

## Impact
- No sitemap reference
- Aggressive bots can overload server
- No crawl control

## Fix
Add production-ready robots.txt

## Dependencies
Should reference sitemap from SEO-002

## Files to Change
- \`public/robots.txt\`

## Acceptance Criteria
- [ ] Sitemap URL referenced
- [ ] User-agent directives set
- [ ] Crawl-delay configured
- [ ] Disallow patterns for admin/search results
- [ ] Validates at robotstxt.org

## Reference
See \`seo-audit.md\` section 1.1

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,size: XS (< 1hr)"

create_issue \
    "[SEO-005] Add Open Graph and Twitter Card tags" \
    "## Problem
No social sharing meta tags. Poor social media previews.

## Impact
- 60% less social engagement
- Unprofessional appearance when shared
- Lost viral traffic

## Fix
Add OG and Twitter Card tags

## Files to Change
- \`app/views/layouts/application.html.erb\`
- \`app/views/search/results.html.erb\`

## Action Items
- [ ] Create default social images (1200x630, 1200x675)

## Acceptance Criteria
- [ ] OG tags in layout
- [ ] Dynamic OG tags for song results
- [ ] Twitter Card tags
- [ ] Default social images created
- [ ] Validates on Facebook Debugger
- [ ] Validates on Twitter Card Validator

## Testing
- https://developers.facebook.com/tools/debug/
- https://cards-dev.twitter.com/validator

## Reference
See \`seo-audit.md\` section 2.2

## Estimate
1-2 hours" \
    "priority: P1 - high,type: seo,size: S (1-2hrs)"

create_issue \
    "[SEO-006] Add canonical tags to prevent duplicate content" \
    "## Problem
No canonical tags. Query parameters create duplicate content risk.

## Impact
- Wrong URLs indexed
- Diluted link equity
- Duplicate content penalties

## Fix
Add canonical link tags with content_for pattern

## Files to Change
- \`app/views/layouts/application.html.erb\`
- \`app/helpers/application_helper.rb\`
- \`app/views/search/index.html.erb\`

## Acceptance Criteria
- [ ] Canonical tag in layout
- [ ] Helper method for setting canonical URL
- [ ] Homepage sets canonical to root_url
- [ ] Results page canonical points to homepage
- [ ] Validates in HTML validator

## Reference
See \`seo-audit.md\` section 1.4

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,size: XS (< 1hr)"

create_issue \
    "[SEO-007] Add meta robots tags for indexation control" \
    "## Problem
No meta robots tags. Can't control page indexation.

## Impact
- Search results pages get indexed (duplicate content)
- No control over snippet generation

## Fix
Add meta robots with content_for pattern

## Files to Change
- \`app/views/layouts/application.html.erb\`
- \`app/views/search/results.html.erb\`

## Acceptance Criteria
- [ ] Default: index, follow
- [ ] Results page: noindex, follow
- [ ] Validates in HTML validator

## Reference
See \`seo-audit.md\` section 1.3

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,size: XS (< 1hr)"

create_issue \
    "[SEO-008] Fix heading hierarchy (H1/H2/H3)" \
    "## Problem
Only H1 tags exist. No H2/H3 structure for content organization.

## Impact
- Search engines can't understand content structure
- Poor accessibility
- Missed keyword targeting

## Fix
Add proper heading hierarchy with H2/H3 tags

## Files to Change
- \`app/views/search/index.html.erb\`
- \`app/views/search/results.html.erb\`

## Acceptance Criteria
- [ ] Homepage: H1 → H2 (Features) → H3 (individual features)
- [ ] Results: H1 (song title) → H2 (Buy this song)
- [ ] Decorative SVGs have aria-hidden=\"true\"
- [ ] Logical heading outline in devtools
- [ ] Lighthouse accessibility score improves

## Reference
See \`seo-audit.md\` section 2.3

## Estimate
1-2 hours" \
    "priority: P1 - high,type: seo,size: S (1-2hrs)"

create_issue \
    "[SEO-009] Add language declaration to HTML tag" \
    "## Problem
HTML tag missing lang attribute.

## Impact
- Search engines can't determine language
- Poor international SEO
- Accessibility issues

## Fix
Add lang=\"en\" to HTML tag

## Files to Change
- \`app/views/layouts/application.html.erb\`

## Acceptance Criteria
- [ ] \`<html lang=\"en\">\`
- [ ] Validates in HTML validator

## Future Enhancement
Consider using I18n.locale for future i18n support

## Reference
See \`seo-audit.md\` section 2.4

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,size: XS (< 1hr)"

create_issue \
    "[SEO-010] Add lazy loading to iframe and images" \
    "## Problem
YouTube iframe loads immediately, slowing page load.

## Impact
- Poor Core Web Vitals (LCP)
- Slower initial page load
- Wasted bandwidth

## Fix
Add loading=\"lazy\" and proper title to iframe

## Files to Change
- \`app/views/search/results.html.erb\`

## Acceptance Criteria
- [ ] iframe has loading=\"lazy\"
- [ ] iframe has descriptive title attribute
- [ ] Images have loading=\"lazy\"
- [ ] PageSpeed Insights score improves
- [ ] YouTube video still plays correctly

## Reference
See \`seo-audit.md\` section 3.5

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,type: performance,size: XS (< 1hr)"

create_issue \
    "[SEO-011] Complete favicon implementation" \
    "## Problem
Incomplete favicon set. May not work across all browsers.

## Impact
- Poor branding on some devices
- Unprofessional appearance
- Browser warnings

## Fix
Generate complete favicon set and update markup

## Files to Change
- \`app/views/layouts/application.html.erb\`
- \`public/favicon-*.png\` (create)
- \`public/apple-touch-icon.png\` (create)
- \`public/safari-pinned-tab.svg\` (create)

## Action Items
- [ ] Generate favicons at https://realfavicongenerator.net/

## Acceptance Criteria
- [ ] All favicon sizes generated
- [ ] Files placed in public/
- [ ] Layout references all icons
- [ ] Icons display correctly in all browsers
- [ ] Validates at realfavicongenerator.net

## Reference
See \`seo-audit.md\` section 3.2

## Estimate
< 1 hour" \
    "priority: P1 - high,type: seo,size: XS (< 1hr)"

echo ""
echo "📋 Creating P2 (Medium) issues..."
echo ""

# Create remaining P2 issues (abbreviated for brevity)
create_issue \
    "[SECURITY-011] Enable host authorization in production" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Enable host authorization to prevent DNS rebinding attacks.

## Files
- \`config/environments/production.rb\`
- \`config/environments/development.rb\`

## Estimate
< 1 hour" \
    "priority: P2 - medium,type: security,size: XS (< 1hr)"

create_issue \
    "[SECURITY-012] Improve error messages (no internal exposure)" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Use generic error messages for users, detailed for logs only.

## Files
- \`app/controllers/search_controller.rb\`

## Estimate
< 1 hour" \
    "priority: P2 - medium,type: security,size: XS (< 1hr)"

create_issue \
    "[TEST-001] Add comprehensive service layer tests" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add tests for YouTube, Last.fm, and Genius services (0% → 100% coverage)

## Requirements
- WebMock gem
- 10+ tests per service
- Cover all error scenarios

## Estimate
4-8 hours" \
    "priority: P2 - medium,type: testing,size: L (4-8hrs)"

create_issue \
    "[TEST-002] Expand SearchController tests" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Expand from 1 test to 17+ tests covering all scenarios

## Estimate
2-4 hours" \
    "priority: P2 - medium,type: testing,size: M (2-4hrs)"

create_issue \
    "[TEST-003] Add system tests for search flow" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add end-to-end tests with Capybara/Selenium

## Estimate
2-4 hours" \
    "priority: P2 - medium,type: testing,size: M (2-4hrs)"

create_issue \
    "[TEST-004] Fix null reference bug in SearchController" \
    "## Problem
Line 10 crashes if YouTube returns empty results

## Impact
- Application crashes
- Poor UX

## Fix
Add nil check before accessing youtube_results['items'].first

## Files
- \`app/controllers/search_controller.rb\`

## Estimate
< 1 hour" \
    "priority: P2 - medium,type: testing,size: XS (< 1hr)"

create_issue \
    "[SEO-012] Add rich content to homepage" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add \"How It Works\" section with 150-200 words

## Estimate
2-4 hours" \
    "priority: P2 - medium,type: seo,size: M (2-4hrs)"

create_issue \
    "[SEO-013] Create footer with internal links" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add footer with Privacy, Terms, About, Contact links

## Estimate
1-2 hours" \
    "priority: P2 - medium,type: seo,size: S (1-2hrs)"

create_issue \
    "[SEO-014] Optimize performance (preload, defer)" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add resource preloading and deferring for better Core Web Vitals

## Target
- PageSpeed: 90+ desktop, 80+ mobile
- LCP < 2.5s

## Estimate
1-2 hours" \
    "priority: P2 - medium,type: performance,type: seo,size: S (1-2hrs)"

create_issue \
    "[SEO-015] Add image optimization with WebP" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add image_processing gem and WebP support

## Estimate
1-2 hours" \
    "priority: P2 - medium,type: performance,size: S (1-2hrs)"

echo ""
echo "📋 Creating P3 (Low) issues..."
echo ""

create_issue \
    "[TECH-001] Apply Ruby 4.0.1 upgrade" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Upgrade Ruby 3.3.4 → 4.0.1 (8-12% performance improvement)

## Breaking Changes
- Process::Status#& removed
- Kernel#open with | removed
- Binding#local_variables excludes numbered params

## Estimate
2-4 hours" \
    "priority: P3 - low,type: tech-debt,size: M (2-4hrs)"

create_issue \
    "[TECH-002] Apply Rails 8.1.2 upgrade" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Upgrade Rails 8.0.2 → 8.1.2

## Dependencies
Depends on TECH-001 (Ruby upgrade)

## Estimate
2-4 hours" \
    "priority: P3 - low,type: tech-debt,size: M (2-4hrs)"

create_issue \
    "[TECH-003] Apply Node.js 24.13.0 upgrade" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Upgrade Node 20.14.0 → 24.13.0 LTS (8-12% performance improvement)

## Estimate
1-2 hours" \
    "priority: P3 - low,type: tech-debt,size: S (1-2hrs)"

create_issue \
    "[SEO-016] Refactor URL structure (OPTIONAL)" \
    "See IMPLEMENTATION_PLAN.md for full details.

## ⚠️ WARNING
Major refactor. Consider doing in separate release.

## Quick Summary
Change /search/results?q= to /song/:artist/:title

## Estimate
4-8 hours" \
    "priority: P3 - low,type: seo,size: L (4-8hrs)"

create_issue \
    "[TEST-005] Add code coverage tracking with SimpleCov" \
    "See IMPLEMENTATION_PLAN.md for full details.

## Quick Summary
Add SimpleCov gem for coverage reporting

## Target
> 85% coverage

## Estimate
< 1 hour" \
    "priority: P3 - low,type: testing,size: XS (< 1hr)"

echo ""
echo "✅ All GitHub labels and issues created!"
echo ""
echo "📊 Summary:"
echo "  Labels created: 13 (priority, type, size)"
echo "  - P0 (Critical): 8 issues"
echo "  - P1 (High): 12 issues"
echo "  - P2 (Medium): 10 issues"
echo "  - P3 (Low): 5 issues"
echo "  - TOTAL: 35 issues"
echo ""
echo "🔗 View issues: gh issue list"
echo "🏷️  View labels: gh label list"
echo "📋 View by priority: gh issue list --label 'priority: P0 - critical'"
echo ""
echo "Next steps:"
echo "1. Review issues: gh issue list"
echo "2. Assign issues: gh issue edit <number> --assignee @me"
echo "3. Start with P0 issues first!"
echo ""
echo "💡 Tip: Run this script again to create any missing labels/issues (it's idempotent)"
echo ""
