# frozen_string_literal: true

module Pylon
  module Models
    # An email address Pylon will not send to, either because a message
    # hard bounced or because someone suppressed it manually.
    #
    # Attributes: id, email, reason ("hard_bounce" or "manual"),
    # created_at (RFC3339), bounce_details
    class EmailSuppression < Base
    end
  end
end
