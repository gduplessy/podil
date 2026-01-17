# Podil Implementation Plan - Complete TODO

**Generated:** January 16, 2026
**Total Issues:** 35
**Total Estimated Time:** 45-55 hours
**Organization:** Issues ordered by IMPORTANCE → EASE OF IMPLEMENTATION

---

## 📋 Quick Reference

### Issue Count by Priority
- **🔴 P0 (Critical):** 8 issues - ~14 hours - BLOCK PRODUCTION DEPLOY
- **🟠 P1 (High):** 12 issues - ~18 hours - Ship within 1 week
- **🟡 P2 (Medium):** 10 issues - ~15 hours - Ship within 2-4 weeks
- **🟢 P3 (Low):** 5 issues - ~5 hours - Nice to have

### GitHub Labels to Create

```bash
# Priority labels
gh label create "priority: P0 - critical" --color "d73a4a" --description "Blocks production deploy"
gh label create "priority: P1 - high" --color "ff6b35" --description "Ship within 1 week"
gh label create "priority: P2 - medium" --color "fbca04" --description "Ship within 2-4 weeks"
gh label create "priority: P3 - low" --color "0e8a16" --description "Nice to have"

# Type labels
gh label create "type: security" --color "b60205" --description "Security vulnerability"
gh label create "type: seo" --color "5319e7" --description "SEO improvement"
gh label create "type: testing" --color "1d76db" --description "Test coverage"
gh label create "type: tech-debt" --color "d4c5f9" --description "Technical debt"
gh label create "type: performance" --color "bfd4f2" --description "Performance improvement"

# Size labels
gh label create "size: XS (< 1hr)" --color "c2e0c6" --description "Extra small effort"
gh label create "size: S (1-2hrs)" --color "bfe5bf" --description "Small effort"
gh label create "size: M (2-4hrs)" --color "a8dba8" --description "Medium effort"
gh label create "size: L (4-8hrs)" --color "79bd9a" --description "Large effort"
gh label create "size: XL (> 8hrs)" --color "3b8686" --description "Extra large effort"
```

---

## 🔴 P0: CRITICAL - Block Production Deploy (14 hours)

### SECURITY-001: Remove XSS vulnerability via raw() helper
**Priority:** P0 - Critical
**Type:** Security
**Size:** S (1-2hrs)
**CVSS:** 8.2
**Blocks:** All other work

**Issue:**
```markdown
## Problem
Critical XSS vulnerability in `app/views/search/results.html.erb:51` using `raw()` helper.

## Impact
- Session hijacking
- Account takeover
- Data exfiltration

## Fix
Replace raw() with safe SVG partial

## Files to Change
- `app/views/search/results.html.erb`
- `app/views/shared/_music_service_icon.html.erb` (create)
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] No usage of `raw()` helper in views
- [ ] SVG icons render correctly
- [ ] Brakeman scan shows no XSS warnings
- [ ] Tests pass

## Reference
See `security_check.md` SEC-001 for detailed fix
```

**PR Title:** `[SECURITY] Remove XSS vulnerability from music service icons`
**Branch:** `security/remove-raw-xss`

---

### SECURITY-002: Enable Content Security Policy
**Priority:** P0 - Critical
**Type:** Security
**Size:** M (2-4hrs)
**CVSS:** 7.8
**Depends on:** SECURITY-005 (inline JS removal)

**Issue:**
```markdown
## Problem
Content Security Policy completely disabled in `config/initializers/content_security_policy.rb`

## Impact
- No defense against XSS attacks
- Vulnerable to clickjacking
- No protection from malicious scripts

## Fix
Enable and configure CSP with proper directives

## Files to Change
- `config/initializers/content_security_policy.rb`
- `app/controllers/csp_reports_controller.rb` (create)
- `config/routes.rb`

## Acceptance Criteria
- [ ] CSP headers present in HTTP response
- [ ] YouTube embeds still work
- [ ] No inline scripts blocked
- [ ] CSP violation reports logged
- [ ] Tests pass

## Reference
See `security_check.md` SEC-002
```

**PR Title:** `[SECURITY] Enable Content Security Policy`
**Branch:** `security/enable-csp`

---

### SECURITY-003: Add rate limiting with Rack::Attack
**Priority:** P0 - Critical
**Type:** Security
**Size:** S (1-2hrs)
**CVSS:** 7.5

**Issue:**
```markdown
## Problem
No rate limiting on search endpoint. Vulnerable to DoS and API quota exhaustion.

## Impact
- Application downtime
- $$ Cost overruns from API abuse
- IP bans from external APIs

## Fix
Install and configure Rack::Attack gem

## Files to Change
- `Gemfile`
- `config/initializers/rack_attack.rb` (create)
- `config/application.rb`
- `public/429.html` (create)

## Acceptance Criteria
- [ ] Rate limit: 10 searches/minute per IP
- [ ] Rate limit: 300 requests/5min per IP (general)
- [ ] 429 error page displays correctly
- [ ] Localhost bypasses rate limit
- [ ] Tests verify rate limiting works

## Reference
See `security_check.md` SEC-003
```

**PR Title:** `[SECURITY] Add rate limiting to prevent DoS attacks`
**Branch:** `security/add-rate-limiting`

---

### SECURITY-004: Add input validation on query parameter
**Priority:** P0 - Critical
**Type:** Security
**Size:** S (1-2hrs)
**CVSS:** 6.8

**Issue:**
```markdown
## Problem
No validation on search query parameter in `SearchController#results`

## Impact
- XSS attacks
- Application crashes from nil/empty queries
- API abuse from extremely long strings

## Fix
Add comprehensive input validation

## Files to Change
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] Blank queries return error message
- [ ] Queries > 200 chars rejected
- [ ] Special characters (`<>"'`) rejected
- [ ] Query sanitized before API calls
- [ ] User-friendly error messages
- [ ] Tests cover all edge cases

## Reference
See `security_check.md` SEC-004
```

**PR Title:** `[SECURITY] Add input validation to search controller`
**Branch:** `security/validate-search-input`

---

### SECURITY-005: Remove inline JavaScript from views
**Priority:** P0 - Critical
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 6.5
**Blocks:** SECURITY-002 (CSP)

**Issue:**
```markdown
## Problem
Inline JavaScript in `app/views/search/results.html.erb:15-19` violates CSP

## Impact
- Blocks CSP implementation
- Potential XSS vector

## Fix
Move to Stimulus controller or use Turbo link

## Files to Change
- `app/views/search/results.html.erb`
- `app/javascript/controllers/alert_controller.js` (option 1)

## Acceptance Criteria
- [ ] No inline <script> tags in views
- [ ] Alert close button still works
- [ ] CSP allows the solution
- [ ] Tests pass

## Reference
See `security_check.md` SEC-005
```

**PR Title:** `[SECURITY] Remove inline JavaScript for CSP compliance`
**Branch:** `security/remove-inline-js`

---

### SEO-001: Add meta descriptions to all pages
**Priority:** P0 - Critical
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
No meta descriptions on any pages. 0% SERP optimization.

## Impact
- 0-30% lower click-through rates
- Google writes poor quality descriptions
- Lost keyword targeting opportunity

## Fix
Add meta description tags with content_for pattern

## Files to Change
- `app/views/layouts/application.html.erb`
- `app/views/search/index.html.erb`
- `app/views/search/results.html.erb`

## Acceptance Criteria
- [ ] Default meta description in layout
- [ ] Homepage has specific description (150-160 chars)
- [ ] Results page has dynamic description with song/artist
- [ ] Meta tags validate in HTML validator
- [ ] Lighthouse SEO score improves

## Reference
See `seo-audit.md` section 2.1
```

**PR Title:** `[SEO] Add meta descriptions to improve SERP CTR`
**Branch:** `seo/add-meta-descriptions`

---

### SEO-002: Generate and configure sitemap.xml
**Priority:** P0 - Critical
**Type:** SEO
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
No sitemap.xml exists. Search engines can't discover pages efficiently.

## Impact
- Slower indexing
- Search engines may miss pages
- No crawl priority control

## Fix
Install sitemap_generator gem and configure

## Files to Change
- `Gemfile`
- `config/sitemap.rb` (create)
- `.gitignore`
- `public/robots.txt` (update)

## Acceptance Criteria
- [ ] sitemap_generator gem installed
- [ ] Sitemap generates successfully
- [ ] Sitemap includes homepage and search page
- [ ] robots.txt references sitemap
- [ ] Sitemap validates in Google Search Console

## Commands
```bash
bundle exec rake sitemap:refresh
```

## Reference
See `seo-audit.md` section 1.2
```

**PR Title:** `[SEO] Add sitemap.xml for better search engine discovery`
**Branch:** `seo/add-sitemap`

---

### SEO-003: Add structured data (Schema.org)
**Priority:** P0 - Critical
**Type:** SEO
**Size:** M (2-4hrs)

**Issue:**
```markdown
## Problem
No structured data markup. Missing rich snippets and music carousels in search results.

## Impact
- No rich snippets
- Lost traffic from music-specific features
- Competitors with schema outrank us

## Fix
Add MusicRecording, WebSite, and Breadcrumb schemas

## Files to Change
- `app/views/search/results.html.erb`
- `app/views/search/index.html.erb`

## Acceptance Criteria
- [ ] MusicRecording schema on results page
- [ ] WebSite + SearchAction schema on homepage
- [ ] Breadcrumb schema on results page
- [ ] Zero errors in Google Rich Results Test
- [ ] Schema validates on schema.org validator

## Testing URLs
- https://search.google.com/test/rich-results
- https://validator.schema.org/

## Reference
See `seo-audit.md` section 3.1
```

**PR Title:** `[SEO] Add Schema.org structured data for rich snippets`
**Branch:** `seo/add-structured-data`

---

## 🟠 P1: HIGH - Ship Within 1 Week (18 hours)

### SECURITY-006: Add API key validation at startup
**Priority:** P1 - High
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 6.2

**Issue:**
```markdown
## Problem
No validation that required API keys are set. App crashes with confusing errors.

## Impact
- Production crashes
- Failed deployments
- Confusing error messages

## Fix
Add initializer to validate API keys at startup

## Files to Change
- `config/initializers/api_keys.rb` (create)
- `app/services/youtube_service.rb`
- `app/services/lastfm_service.rb`
- `app/services/genius_service.rb`

## Acceptance Criteria
- [ ] App fails to start if keys missing (production)
- [ ] Warning shown in development if keys missing
- [ ] Clear error messages indicate which keys are missing
- [ ] Tests cover missing key scenarios

## Reference
See `security_check.md` SEC-006
```

**PR Title:** `[SECURITY] Validate API keys at application startup`
**Branch:** `security/validate-api-keys`

---

### SECURITY-007: Change search forms to POST method
**Priority:** P1 - High
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 5.5

**Issue:**
```markdown
## Problem
Search forms use GET method. Search queries leak via browser history and referrer headers.

## Impact
- Privacy leak via browser history
- Referrer header leakage
- No CSRF protection

## Fix
Change forms to POST method with CSRF tokens

## Files to Change
- `app/views/search/index.html.erb`
- `app/views/search/results.html.erb`
- `config/routes.rb`

## Acceptance Criteria
- [ ] Forms use POST method
- [ ] CSRF tokens included automatically
- [ ] Search queries not in browser history
- [ ] Tests updated for POST requests

## Reference
See `security_check.md` SEC-007
```

**PR Title:** `[SECURITY] Change search forms to POST for privacy`
**Branch:** `security/forms-to-post`

---

### SECURITY-008: Add security headers
**Priority:** P1 - High
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 5.3

**Issue:**
```markdown
## Problem
Missing important security headers (X-Frame-Options, X-Content-Type-Options, etc.)

## Impact
- Clickjacking attacks
- MIME sniffing attacks
- Information leakage

## Fix
Configure security headers in initializer

## Files to Change
- `config/initializers/security_headers.rb` (create)

## Acceptance Criteria
- [ ] X-Frame-Options: DENY
- [ ] X-Content-Type-Options: nosniff
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] Permissions-Policy set
- [ ] HSTS enabled in production
- [ ] SecurityHeaders.com score: A+

## Testing
```bash
curl -I http://localhost:3000 | grep -E 'X-Frame|X-Content'
```

## Reference
See `security_check.md` SEC-008
```

**PR Title:** `[SECURITY] Add security headers for defense in depth`
**Branch:** `security/add-headers`

---

### SECURITY-009: Configure API request timeouts
**Priority:** P1 - High
**Type:** Security
**Size:** S (1-2hrs)
**CVSS:** 5.0

**Issue:**
```markdown
## Problem
HTTParty requests have no timeout. Hanging APIs block app indefinitely.

## Impact
- Resource exhaustion
- DoS via slow APIs
- Poor UX (page never loads)

## Fix
Add timeout configuration to all services with retry logic

## Files to Change
- `app/services/youtube_service.rb`
- `app/services/lastfm_service.rb`
- `app/services/genius_service.rb`
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] All services have 5s total timeout
- [ ] 2s connection timeout, 3s read timeout
- [ ] 3 retries for transient failures
- [ ] Controller handles timeout exceptions gracefully
- [ ] Tests cover timeout scenarios

## Reference
See `security_check.md` SEC-009
```

**PR Title:** `[SECURITY] Add timeouts to prevent hanging requests`
**Branch:** `security/add-api-timeouts`

---

### SECURITY-010: URL-encode user input in purchase links
**Priority:** P1 - High
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 4.8

**Issue:**
```markdown
## Problem
Song titles not URL-encoded in purchase links. Special characters break URLs.

## Impact
- Broken links
- Potential open redirect
- Poor UX

## Fix
Use ERB::Util.url_encode for all URL parameters

## Files to Change
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] All song titles URL-encoded in purchase links
- [ ] Special characters (&?#=) handled correctly
- [ ] Links work for songs with special chars
- [ ] Tests cover URL encoding

## Reference
See `security_check.md` SEC-010
```

**PR Title:** `[SECURITY] URL-encode song titles in purchase links`
**Branch:** `security/url-encode-titles`

---

### SEO-004: Update robots.txt with proper directives
**Priority:** P1 - High
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
robots.txt is empty. No crawler guidance.

## Impact
- No sitemap reference
- Aggressive bots can overload server
- No crawl control

## Fix
Add production-ready robots.txt

## Files to Change
- `public/robots.txt`

## Acceptance Criteria
- [ ] Sitemap URL referenced
- [ ] User-agent directives set
- [ ] Crawl-delay configured
- [ ] Disallow patterns for admin/search results
- [ ] Validates at robotstxt.org

## Reference
See `seo-audit.md` section 1.1
```

**PR Title:** `[SEO] Update robots.txt with sitemap and crawl directives`
**Branch:** `seo/update-robots-txt`

---

### SEO-005: Add Open Graph and Twitter Card tags
**Priority:** P1 - High
**Type:** SEO
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
No social sharing meta tags. Poor social media previews.

## Impact
- 60% less social engagement
- Unprofessional appearance when shared
- Lost viral traffic

## Fix
Add OG and Twitter Card tags

## Files to Change
- `app/views/layouts/application.html.erb`
- `app/views/search/results.html.erb`

## Acceptance Criteria
- [ ] OG tags in layout
- [ ] Dynamic OG tags for song results
- [ ] Twitter Card tags
- [ ] Default social images created (1200x630, 1200x675)
- [ ] Validates on Facebook Debugger
- [ ] Validates on Twitter Card Validator

## Testing URLs
- https://developers.facebook.com/tools/debug/
- https://cards-dev.twitter.com/validator

## Reference
See `seo-audit.md` section 2.2
```

**PR Title:** `[SEO] Add Open Graph and Twitter Card tags for social sharing`
**Branch:** `seo/add-social-tags`

---

### SEO-006: Add canonical tags to prevent duplicate content
**Priority:** P1 - High
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
No canonical tags. Query parameters create duplicate content risk.

## Impact
- Wrong URLs indexed
- Diluted link equity
- Duplicate content penalties

## Fix
Add canonical link tags with content_for pattern

## Files to Change
- `app/views/layouts/application.html.erb`
- `app/helpers/application_helper.rb`
- `app/views/search/index.html.erb`

## Acceptance Criteria
- [ ] Canonical tag in layout
- [ ] Helper method for setting canonical URL
- [ ] Homepage sets canonical to root_url
- [ ] Results page canonical points to homepage (noindex)
- [ ] Validates in HTML validator

## Reference
See `seo-audit.md` section 1.4
```

**PR Title:** `[SEO] Add canonical tags to prevent duplicate content`
**Branch:** `seo/add-canonical-tags`

---

### SEO-007: Add meta robots tags for indexation control
**Priority:** P1 - High
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
No meta robots tags. Can't control page indexation.

## Impact
- Search results pages get indexed (duplicate content)
- No control over snippet generation

## Fix
Add meta robots with content_for pattern

## Files to Change
- `app/views/layouts/application.html.erb`
- `app/views/search/results.html.erb`

## Acceptance Criteria
- [ ] Default: index, follow
- [ ] Results page: noindex, follow
- [ ] 404 page already has noindex (verified)
- [ ] Validates in HTML validator

## Reference
See `seo-audit.md` section 1.3
```

**PR Title:** `[SEO] Add meta robots tags for indexation control`
**Branch:** `seo/add-meta-robots`

---

### SEO-008: Fix heading hierarchy (H1/H2/H3)
**Priority:** P1 - High
**Type:** SEO
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
Only H1 tags exist. No H2/H3 structure for content organization.

## Impact
- Search engines can't understand content structure
- Poor accessibility
- Missed keyword targeting

## Fix
Add proper heading hierarchy with H2/H3 tags

## Files to Change
- `app/views/search/index.html.erb`
- `app/views/search/results.html.erb`

## Acceptance Criteria
- [ ] Homepage: H1 → H2 (Features) → H3 (individual features)
- [ ] Results: H1 (song title) → H2 (Buy this song)
- [ ] Decorative SVGs have aria-hidden="true"
- [ ] Logical heading outline in devtools
- [ ] Lighthouse accessibility score improves

## Reference
See `seo-audit.md` section 2.3
```

**PR Title:** `[SEO] Improve heading hierarchy for accessibility and SEO`
**Branch:** `seo/fix-heading-hierarchy`

---

### SEO-009: Add language declaration to HTML tag
**Priority:** P1 - High
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
HTML tag missing lang attribute.

## Impact
- Search engines can't determine language
- Poor international SEO
- Accessibility issues

## Fix
Add lang="en" to HTML tag

## Files to Change
- `app/views/layouts/application.html.erb`

## Acceptance Criteria
- [ ] <html lang="en">
- [ ] Validates in HTML validator
- [ ] Consider I18n.locale for future i18n support

## Reference
See `seo-audit.md` section 2.4
```

**PR Title:** `[SEO] Add language declaration to HTML tag`
**Branch:** `seo/add-lang-attribute`

---

### SEO-010: Add lazy loading to iframe and images
**Priority:** P1 - High
**Type:** SEO, Performance
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
YouTube iframe loads immediately, slowing page load.

## Impact
- Poor Core Web Vitals (LCP)
- Slower initial page load
- Wasted bandwidth

## Fix
Add loading="lazy" and proper title to iframe

## Files to Change
- `app/views/search/results.html.erb`

## Acceptance Criteria
- [ ] iframe has loading="lazy"
- [ ] iframe has descriptive title attribute
- [ ] Images have loading="lazy"
- [ ] PageSpeed Insights score improves
- [ ] YouTube video still plays correctly

## Reference
See `seo-audit.md` section 3.5
```

**PR Title:** `[SEO][PERF] Add lazy loading to improve page speed`
**Branch:** `seo/add-lazy-loading`

---

### SEO-011: Complete favicon implementation
**Priority:** P1 - High
**Type:** SEO
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
Incomplete favicon set. May not work across all browsers.

## Impact
- Poor branding on some devices
- Unprofessional appearance
- Browser warnings

## Fix
Generate complete favicon set and update markup

## Files to Change
- `app/views/layouts/application.html.erb`
- `public/favicon-*.png` (create)
- `public/apple-touch-icon.png` (create)
- `public/safari-pinned-tab.svg` (create)

## Acceptance Criteria
- [ ] All favicon sizes generated
- [ ] Files placed in public/
- [ ] Layout references all icons
- [ ] Icons display correctly in all browsers
- [ ] Validates at realfavicongenerator.net

## Tool
https://realfavicongenerator.net/

## Reference
See `seo-audit.md` section 3.2
```

**PR Title:** `[SEO] Complete favicon implementation for all browsers`
**Branch:** `seo/complete-favicons`

---

## 🟡 P2: MEDIUM - Ship Within 2-4 Weeks (15 hours)

### SECURITY-011: Enable host authorization in production
**Priority:** P2 - Medium
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 4.5

**Issue:**
```markdown
## Problem
Host authorization commented out. Vulnerable to DNS rebinding.

## Impact
- DNS rebinding attacks
- Cache poisoning
- Host header manipulation

## Fix
Uncomment and configure hosts whitelist

## Files to Change
- `config/environments/production.rb`
- `config/environments/development.rb`

## Acceptance Criteria
- [ ] Production: hosts whitelist configured
- [ ] Development: all hosts allowed
- [ ] Health check endpoint bypasses restriction
- [ ] Tests cover host validation

## Reference
See `security_check.md` SEC-011
```

**PR Title:** `[SECURITY] Enable host authorization to prevent DNS rebinding`
**Branch:** `security/enable-host-auth`

---

### SECURITY-012: Improve error messages (no internal exposure)
**Priority:** P2 - Medium
**Type:** Security
**Size:** XS (< 1hr)
**CVSS:** 3.2

**Issue:**
```markdown
## Problem
Error messages expose internal details (mentions Last.fm, etc.)

## Impact
- Information disclosure
- Easier targeted attacks

## Fix
Use generic error messages for users, detailed for logs

## Files to Change
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] User errors are generic
- [ ] Detailed errors logged internally
- [ ] No tech stack details in user-facing errors
- [ ] Tests verify error message format

## Reference
See `security_check.md` SEC-012
```

**PR Title:** `[SECURITY] Sanitize error messages to prevent info disclosure`
**Branch:** `security/sanitize-errors`

---

### TEST-001: Add comprehensive service layer tests
**Priority:** P2 - Medium
**Type:** Testing
**Size:** L (4-8hrs)

**Issue:**
```markdown
## Problem
0% test coverage on all service classes (YouTube, Last.fm, Genius)

## Impact
- Unknown bugs in production
- Fragile codebase
- Difficult to refactor

## Fix
Add comprehensive service tests with WebMock

## Files to Change
- `Gemfile` (add webmock)
- `test/services/youtube_service_test.rb` (create)
- `test/services/lastfm_service_test.rb` (create)
- `test/services/genius_service_test.rb` (create)
- `test/test_helper.rb`

## Acceptance Criteria
- [ ] WebMock gem installed
- [ ] 10+ tests per service (happy path + errors)
- [ ] Test: successful API calls
- [ ] Test: empty results
- [ ] Test: API errors (4xx, 5xx)
- [ ] Test: timeouts
- [ ] Test: missing API keys
- [ ] Test: special characters
- [ ] 100% service coverage
- [ ] All tests pass

## Reference
Test coverage report section 2
```

**PR Title:** `[TEST] Add comprehensive service layer tests`
**Branch:** `test/add-service-tests`

---

### TEST-002: Expand SearchController tests
**Priority:** P2 - Medium
**Type:** Testing
**Size:** M (2-4hrs)

**Issue:**
```markdown
## Problem
Only 1 trivial test exists for SearchController. ~5% coverage.

## Impact
- Critical null reference bug undetected (line 10)
- Unknown edge cases
- Regression risks

## Fix
Add 17+ controller tests covering all scenarios

## Files to Change
- `test/controllers/search_controller_test.rb`

## Acceptance Criteria
- [ ] Test: happy path (valid search)
- [ ] Test: YouTube empty results
- [ ] Test: Last.fm failures
- [ ] Test: missing query parameter
- [ ] Test: empty query
- [ ] Test: very long query
- [ ] Test: special characters
- [ ] Test: XSS attempts
- [ ] Test: null reference bug (line 10) fixed
- [ ] 90%+ controller coverage
- [ ] All tests pass

## Reference
Test coverage report section 2B
```

**PR Title:** `[TEST] Expand SearchController test coverage`
**Branch:** `test/expand-controller-tests`

---

### TEST-003: Add system tests for search flow
**Priority:** P2 - Medium
**Type:** Testing
**Size:** M (2-4hrs)

**Issue:**
```markdown
## Problem
0% system test coverage. No end-to-end testing.

## Impact
- Integration bugs missed
- User flows untested
- Deployment risks

## Fix
Create system tests with Capybara/Selenium

## Files to Change
- `test/system/search_flow_test.rb` (create)

## Acceptance Criteria
- [ ] Test: user can search for a song
- [ ] Test: video player displays
- [ ] Test: purchase links appear
- [ ] Test: error message for invalid search
- [ ] Test: user can return to search
- [ ] Test: alert dismissal works
- [ ] All system tests pass in headless Chrome

## Reference
Test coverage report section 2C
```

**PR Title:** `[TEST] Add system tests for search flow`
**Branch:** `test/add-system-tests`

---

### TEST-004: Fix null reference bug in SearchController
**Priority:** P2 - Medium
**Type:** Bug, Testing
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
Line 10 of SearchController crashes if YouTube returns empty results

## Impact
- Application crashes
- Poor error handling
- Bad UX

## Fix
Add nil check before accessing youtube_results['items'].first

## Files to Change
- `app/controllers/search_controller.rb`

## Acceptance Criteria
- [ ] Check if youtube_results['items'] is present
- [ ] Check if .first is not nil
- [ ] Show error if no results
- [ ] Test covers empty results scenario
- [ ] No crashes on empty YouTube response

## Reference
Test coverage report - "Critical Bugs Found During Analysis"
```

**PR Title:** `[BUG] Fix null reference crash when YouTube returns empty results`
**Branch:** `bugfix/youtube-null-check`

---

### SEO-012: Add rich content to homepage
**Priority:** P2 - Medium
**Type:** SEO
**Size:** M (2-4hrs)

**Issue:**
```markdown
## Problem
Homepage has thin content (minimal text, only ~50 words)

## Impact
- Low keyword density
- Difficult for Google to understand purpose
- May be ranked as "thin content"

## Fix
Add "How It Works" section with 150-200 words

## Files to Change
- `app/views/search/index.html.erb`

## Acceptance Criteria
- [ ] How It Works section added
- [ ] 150-200 words of keyword-rich content
- [ ] Mobile responsive
- [ ] Proper heading structure (H2/H3)
- [ ] Natural language (not keyword stuffed)
- [ ] Lighthouse SEO score improves

## Reference
See `seo-audit.md` section 4.1
```

**PR Title:** `[SEO] Add rich content to homepage for better rankings`
**Branch:** `seo/add-homepage-content`

---

### SEO-013: Create footer with internal links
**Priority:** P2 - Medium
**Type:** SEO
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
No footer with important links (Privacy, Terms, About, Contact)

## Impact
- Poor site architecture
- No trust signals
- May violate GDPR/CCPA
- Weak internal linking

## Fix
Create shared footer partial with links

## Files to Change
- `app/views/shared/_footer.html.erb` (create)
- `app/views/layouts/application.html.erb`
- Create placeholder pages (about, privacy, terms, contact)
- `config/routes.rb`

## Acceptance Criteria
- [ ] Footer renders on all pages
- [ ] Links to About, Privacy, Terms, Contact
- [ ] Links to supported platforms
- [ ] Copyright notice
- [ ] Mobile responsive
- [ ] All links work

## Reference
See `seo-audit.md` section 4.2
```

**PR Title:** `[SEO] Add footer with internal links and legal pages`
**Branch:** `seo/add-footer`

---

### SEO-014: Optimize performance (preload, defer)
**Priority:** P2 - Medium
**Type:** Performance, SEO
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
Render-blocking CSS/JS in head. Poor Core Web Vitals.

## Impact
- Slower LCP
- Poor PageSpeed score
- Lower search rankings

## Fix
Add preload for critical resources, defer non-critical

## Files to Change
- `app/views/layouts/application.html.erb`

## Acceptance Criteria
- [ ] CSS preloaded
- [ ] JavaScript deferred
- [ ] Preconnect hints for external domains (YouTube, Last.fm)
- [ ] PageSpeed score > 80 (mobile), > 90 (desktop)
- [ ] LCP < 2.5s
- [ ] No visual regression

## Testing
https://pagespeed.web.dev/

## Reference
See `seo-audit.md` section 3.3
```

**PR Title:** `[PERF][SEO] Optimize resource loading for Core Web Vitals`
**Branch:** `perf/optimize-loading`

---

### SEO-015: Add image optimization with WebP
**Priority:** P2 - Medium
**Type:** Performance
**Size:** S (1-2hrs)

**Issue:**
```markdown
## Problem
No WebP support. Images not optimized.

## Impact
- Large file sizes
- Slow load times
- Poor mobile performance

## Fix
Add image_processing gem and optimize images

## Files to Change
- `Gemfile`
- Update image_tag calls with lazy loading
- Convert images to WebP

## Acceptance Criteria
- [ ] image_processing gem installed
- [ ] Images lazy loaded
- [ ] WebP versions created
- [ ] Fallback to original format
- [ ] File sizes reduced 30%+
- [ ] Images render correctly

## Reference
See `seo-audit.md` section 3.4
```

**PR Title:** `[PERF] Add image optimization with WebP support`
**Branch:** `perf/optimize-images`

---

## 🟢 P3: LOW - Nice to Have (5 hours)

### TECH-001: Apply Ruby 4.0.1 upgrade
**Priority:** P3 - Low
**Type:** Tech Debt
**Size:** M (2-4hrs)
**Depends on:** All tests passing

**Issue:**
```markdown
## Problem
Ruby 3.3.4 is outdated. Ruby 4.0.1 available with performance improvements.

## Impact
- Missing performance improvements (8-12% faster)
- Missing security patches
- Technical debt

## Fix
Upgrade Ruby version and handle breaking changes

## Files to Change
- `.ruby-version`
- Update bundler
- Fix deprecated code (Kernel#open, etc.)

## Acceptance Criteria
- [ ] Ruby 4.0.1 installed
- [ ] All gems compatible
- [ ] All tests pass
- [ ] No deprecation warnings
- [ ] Deployment successful

## Breaking Changes
- Process::Status#& removed
- Kernel#open with | removed
- Binding#local_variables excludes numbered params

## Reference
Tech stack upgrade report section 1
```

**PR Title:** `[UPGRADE] Upgrade Ruby 3.3.4 → 4.0.1`
**Branch:** `upgrade/ruby-4`

---

### TECH-002: Apply Rails 8.1.2 upgrade
**Priority:** P3 - Low
**Type:** Tech Debt
**Size:** M (2-4hrs)
**Depends on:** TECH-001

**Issue:**
```markdown
## Problem
Rails 8.0.2 is outdated. Rails 8.1.2 available.

## Impact
- Missing features
- Missing security patches
- Technical debt

## Fix
Upgrade Rails version and handle breaking changes

## Files to Change
- `Gemfile`
- Update all gem versions
- Fix deprecated code

## Acceptance Criteria
- [ ] Rails 8.1.2 installed
- [ ] All dependencies updated
- [ ] Database schema regenerated (sorted columns)
- [ ] All tests pass
- [ ] No deprecation warnings
- [ ] Deployment successful

## Breaking Changes
- ActiveRecord columns sorted alphabetically in schema.rb
- Removed :retries option for SQLite3
- Removed deprecated ActiveJob config

## Reference
Tech stack upgrade report section 2
```

**PR Title:** `[UPGRADE] Upgrade Rails 8.0.2 → 8.1.2`
**Branch:** `upgrade/rails-8-1`

---

### TECH-003: Apply Node.js 24.13.0 upgrade
**Priority:** P3 - Low
**Type:** Tech Debt
**Size:** S (1-2hrs)
**Depends on:** All tests passing

**Issue:**
```markdown
## Problem
Node 20.14.0 is outdated. Node 24.13.0 LTS available.

## Impact
- Missing performance improvements (8-12% faster)
- Missing security patches
- Technical debt

## Fix
Upgrade Node version and dependencies

## Files to Change
- `.node-version`
- `package.json`
- Update npm packages

## Acceptance Criteria
- [ ] Node 24.13.0 installed
- [ ] All npm packages compatible
- [ ] esbuild builds successfully
- [ ] Tailwind CSS builds successfully
- [ ] All tests pass
- [ ] No build warnings

## Breaking Changes
- V8 13.6 (may require native module rebuild)
- OpenSSL 3.5
- util.is*() methods removed

## Reference
Tech stack upgrade report section 3
```

**PR Title:** `[UPGRADE] Upgrade Node.js 20.14.0 → 24.13.0 LTS`
**Branch:** `upgrade/node-24`

---

### SEO-016: Refactor URL structure (OPTIONAL)
**Priority:** P3 - Low
**Type:** SEO
**Size:** L (4-8hrs)

**Issue:**
```markdown
## Problem
Search results use query parameters `/search/results?q=` instead of clean URLs.

## Impact
- Query parameter URLs poorly indexed
- Lost keyword context in URL
- Poor UX

## Fix
Change to RESTful URLs like `/song/:artist/:title`

## Files to Change
- `config/routes.rb`
- `app/controllers/songs_controller.rb` (create)
- Update all views
- Add 301 redirects from old URLs
- Update sitemap

## Acceptance Criteria
- [ ] New routes: /song/:artist/:title
- [ ] Old URLs redirect with 301
- [ ] All internal links updated
- [ ] Sitemap updated
- [ ] Tests pass
- [ ] No broken links

## ⚠️ WARNING
Major refactor. Consider doing in separate release.

## Reference
See `seo-audit.md` section 2.5
```

**PR Title:** `[SEO] Refactor to SEO-friendly URL structure`
**Branch:** `seo/refactor-urls`

---

### TEST-005: Add code coverage tracking with SimpleCov
**Priority:** P3 - Low
**Type:** Testing
**Size:** XS (< 1hr)

**Issue:**
```markdown
## Problem
No code coverage tracking. Can't measure test effectiveness.

## Impact
- Unknown test coverage
- Can't identify untested code
- No coverage metrics

## Fix
Add SimpleCov gem and configure

## Files to Change
- `Gemfile`
- `test/test_helper.rb`

## Acceptance Criteria
- [ ] SimpleCov installed
- [ ] Coverage reports generated
- [ ] HTML report viewable
- [ ] Coverage > 85% target
- [ ] CI reports coverage

## Reference
Test coverage report section 4.7
```

**PR Title:** `[TEST] Add code coverage tracking with SimpleCov`
**Branch:** `test/add-coverage`

---

## 📊 Implementation Roadmap

### Week 1: Critical Security & SEO (P0)
**Focus:** Make app production-ready
**Hours:** ~14 hours

**Monday-Tuesday:**
- SECURITY-001: Remove XSS (2hrs)
- SECURITY-005: Remove inline JS (1hr)
- SECURITY-002: Enable CSP (4hrs)

**Wednesday:**
- SECURITY-003: Rate limiting (2hrs)
- SECURITY-004: Input validation (2hrs)

**Thursday-Friday:**
- SEO-001: Meta descriptions (1hr)
- SEO-002: Sitemap (2hrs)
- SEO-003: Structured data (4hrs)

---

### Week 2: High Priority Improvements (P1)
**Focus:** Security hardening + SEO optimization
**Hours:** ~18 hours

**Monday-Tuesday:**
- SECURITY-006: API key validation (1hr)
- SECURITY-007: Forms to POST (1hr)
- SECURITY-008: Security headers (1hr)
- SECURITY-009: API timeouts (2hrs)
- SECURITY-010: URL encoding (1hr)

**Wednesday-Thursday:**
- SEO-004: robots.txt (1hr)
- SEO-005: Social tags (2hrs)
- SEO-006: Canonical tags (1hr)
- SEO-007: Meta robots (1hr)
- SEO-008: Heading hierarchy (2hrs)

**Friday:**
- SEO-009: Language attribute (1hr)
- SEO-010: Lazy loading (1hr)
- SEO-011: Favicons (1hr)

---

### Week 3-4: Testing & Content (P2)
**Focus:** Test coverage + SEO content
**Hours:** ~15 hours

**Week 3:**
- TEST-004: Fix null reference bug (1hr)
- TEST-001: Service tests (8hrs)
- TEST-002: Controller tests (4hrs)

**Week 4:**
- TEST-003: System tests (4hrs)
- SEO-012: Homepage content (2hrs)
- SEO-013: Footer (2hrs)
- SEO-014: Performance (2hrs)
- SEO-015: Images (2hrs)
- SECURITY-011: Host auth (1hr)
- SECURITY-012: Error messages (1hr)

---

### Week 5+: Tech Upgrades (P3) - OPTIONAL
**Focus:** Upgrade dependencies
**Hours:** ~5 hours

- TECH-001: Ruby upgrade (3hrs)
- TECH-002: Rails upgrade (3hrs)
- TECH-003: Node upgrade (2hrs)
- TEST-005: Coverage tracking (1hr)

---

## 🔄 Pull Request Workflow

### Branch Naming Convention
```
security/[issue-description]   # SECURITY-XXX issues
seo/[issue-description]        # SEO-XXX issues
test/[issue-description]       # TEST-XXX issues
bugfix/[issue-description]     # Bug fixes
upgrade/[dependency-name]      # TECH-XXX upgrades
```

### PR Template
```markdown
## Issue
Closes #[issue-number]

## Changes
- [ ] Brief description of change 1
- [ ] Brief description of change 2

## Type of Change
- [ ] 🔒 Security fix (SECURITY-XXX)
- [ ] 🎯 SEO improvement (SEO-XXX)
- [ ] ✅ Test coverage (TEST-XXX)
- [ ] 🐛 Bug fix (bugfix/)
- [ ] ⬆️ Dependency upgrade (TECH-XXX)

## Testing
- [ ] All existing tests pass
- [ ] New tests added (if applicable)
- [ ] Manual testing completed

## Security Checklist (if applicable)
- [ ] No secrets committed
- [ ] Brakeman scan clean
- [ ] bundle-audit clean
- [ ] Input validation added
- [ ] Output sanitized

## SEO Checklist (if applicable)
- [ ] HTML validates
- [ ] Lighthouse SEO score maintained/improved
- [ ] No broken links

## Screenshots/Evidence
[Add screenshots or test output]

## Deployment Notes
[Any special deployment considerations]
```

### Review Requirements
- **P0 (Critical):** 2 approvals required
- **P1 (High):** 1 approval required
- **P2 (Medium):** 1 approval required
- **P3 (Low):** Self-merge allowed with passing CI

---

## 🎯 Success Metrics

### Security Metrics
- [ ] Brakeman: 0 warnings
- [ ] bundle-audit: 0 vulnerabilities
- [ ] SecurityHeaders.com: A+ rating
- [ ] No XSS, CSRF, SQL injection vulnerabilities

### SEO Metrics
- [ ] Lighthouse SEO: 100/100
- [ ] Google Search Console: 0 errors
- [ ] Structured data: 0 errors
- [ ] PageSpeed: 90+ (desktop), 80+ (mobile)

### Testing Metrics
- [ ] Test coverage: > 85%
- [ ] Service coverage: 100%
- [ ] Controller coverage: > 90%
- [ ] System tests: 4+ scenarios

---

## 🚀 Quick Start Commands

### Create all GitHub labels
```bash
bash -c "$(cat <<'EOF'
# Priority
gh label create "priority: P0 - critical" --color "d73a4a" --description "Blocks production deploy"
gh label create "priority: P1 - high" --color "ff6b35" --description "Ship within 1 week"
gh label create "priority: P2 - medium" --color "fbca04" --description "Ship within 2-4 weeks"
gh label create "priority: P3 - low" --color "0e8a16" --description "Nice to have"

# Type
gh label create "type: security" --color "b60205" --description "Security vulnerability"
gh label create "type: seo" --color "5319e7" --description "SEO improvement"
gh label create "type: testing" --color "1d76db" --description "Test coverage"
gh label create "type: tech-debt" --color "d4c5f9" --description "Technical debt"
gh label create "type: performance" --color "bfd4f2" --description "Performance improvement"

# Size
gh label create "size: XS (< 1hr)" --color "c2e0c6" --description "Extra small effort"
gh label create "size: S (1-2hrs)" --color "bfe5bf" --description "Small effort"
gh label create "size: M (2-4hrs)" --color "a8dba8" --description "Medium effort"
gh label create "size: L (4-8hrs)" --color "79bd9a" --description "Large effort"
gh label create "size: XL (> 8hrs)" --color "3b8686" --description "Extra large effort"
EOF
)"
```

### Generate all GitHub issues (coming next)
See `GITHUB_ISSUES.sh` script (will create in next message if requested)

---

## 📚 Reference Documents

- **Security:** `security_check.md`
- **SEO:** `seo-audit.md`, `seo-fix-plan.md`
- **Testing:** (from test coverage agent output)
- **Upgrades:** (from tech upgrade agent output)

---

**Total Issues:** 35
**Total Effort:** 45-55 hours
**Target Completion:** 4-5 weeks

**Next Step:** Review this plan, then I can generate a script to create all GitHub issues automatically.
