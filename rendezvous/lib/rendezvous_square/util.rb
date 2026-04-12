require 'base64'
require 'openssl'
require 'active_support/security_utils'
require 'square'

require_relative 'apis/base'
require_relative 'apis/checkout'
require_relative 'apis/customers'
require_relative 'apis/orders'
require_relative 'apis/payments'
require_relative 'apis/refunds'

module RendezvousSquare
  module Util
    def self.is_valid_webhook_event_signature(body_string, signature, signature_key, notification_url)
      return false if body_string.nil? || signature.nil?

      raise 'signature_key is null or empty' if signature_key.blank?
      raise 'notification_url is null or empty' if notification_url.blank?

      # Combine URL and the raw body string
      payload_bytes = "#{notification_url}#{body_string}".force_encoding('utf-8')
      signature_key_bytes = signature_key.dup.force_encoding('utf-8')

      # Compute the hash
      hmac = OpenSSL::HMAC.digest('sha256', signature_key_bytes, payload_bytes)
      hash_base64 = Base64.strict_encode64(hmac)

      # Securely compare
      ActiveSupport::SecurityUtils.secure_compare(hash_base64, signature)
    end
  end
end
