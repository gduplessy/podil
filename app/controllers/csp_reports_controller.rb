class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    violation_report = request.body.read
    Rails.logger.warn "CSP Violation: #{violation_report}"
    head :ok
  end
end
