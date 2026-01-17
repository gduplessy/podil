# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # Allow same-origin for defaults
    policy.default_src :self

    # Allow YouTube embeds (required for video player)
    policy.frame_src :self, "https://www.youtube.com", "https://youtube.com"

    # Allow images from self and data URIs
    policy.img_src :self, :data, :https

    # Allow scripts from self only
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

  # Generate nonces for inline scripts (if needed in the future)
  config.content_security_policy_nonce_generator = ->(request) {
    SecureRandom.base64(16)
  }

  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Start in report-only mode to test (remove this line after testing)
  config.content_security_policy_report_only = true
end
