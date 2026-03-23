# app/lib/rendezvous_square/normalized_item.rb

module RendezvousSquare
  class NormalizedItem
    attr_reader \
      :id,
      :created_at,
      :amount_cents,
      :currency,
      :status,
      :transaction_type,
      :reference_id,
      :email

    def initialize(
      id:,
      created_at:,
      amount_cents: 0,
      currency: "USD",
      status: nil,
      transaction_type:,
      reference_id: nil,
      email: nil
    )
      @id = id
      @created_at = created_at
      @amount_cents = amount_cents
      @currency = currency
      @status = status
      @transaction_type = transaction_type
      @reference_id = reference_id
      @email = normalize_email(email)
    end

    # ---------- Factory ----------

    def self.from(item, type:)
      item.is_a?(Hash) ? from_hash(item, type: type) : from_object(item, type: type)
    end

    # ---------- Builders ----------

    def self.from_object(item, type:)
      amount_cents, currency =
        if type.to_s == "order"
          extract_order_amount(item)
        else
          extract_amount_money(item)
        end

      new(
        id: safe(item, :id),
        created_at: safe(item, :created_at),
        amount_cents: amount_cents,
        currency: currency,
        status: safe(item, :status),
        transaction_type: type.to_s,
        reference_id: safe(item, :reference_id),
        email: extract_email_object(item)
      )
    end

    def self.extract_amount_money(item)
      money = safe(item, :amount_money)
      return [nil, "USD"] unless money

      [money.amount, money.currency || "USD"]
    end

    def self.extract_order_amount(order)
      # 1. Preferred: total_money
      total = safe(order, :total_money)
      if total
        return [total.amount, total.currency || "USD"]
      end

      # 2. Fallback: net_amounts.total_money
      net = safe(order, :net_amounts)
      if net && net.respond_to?(:total_money)
        tm = net.total_money
        return [tm.amount, tm.currency || "USD"] if tm
      end

      # 3. Last resort: sum line items
      line_items = safe(order, :line_items) || []
      sum = line_items.sum do |li|
        money = safe(li, :total_money)
        money&.amount.to_i
      end

      currency =
        line_items.first &&
        safe(safe(line_items.first, :total_money), :currency)

      [sum, currency || "USD"]
    end

    def self.from_hash(item, type:)
      data = item.with_indifferent_access

      amount_money = data[:amount_money] || {}

      new(
        id: data[:id],
        created_at: data[:created_at],
        amount_cents: amount_money[:amount],
        currency: amount_money[:currency],
        status: data[:status],
        transaction_type: type.to_s,
        reference_id: data[:reference_id],
        email: extract_email_hash(data)
      )
    end

    # ---------- Helpers ----------

    def self.safe(obj, method)
      return nil unless obj
      obj.respond_to?(method) ? obj.public_send(method) : nil
    end

    def self.extract_email_object(item)
      return item.customer_email if item.respond_to?(:customer_email)
      return item.buyer_email_address if item.respond_to?(:buyer_email_address)
      return item.receipt_email if item.respond_to?(:receipt_email)
      nil
    end

    def self.extract_email_hash(data)
      data[:customer_email] ||
        data[:buyer_email_address] ||
        data[:receipt_email]
    end

    def coerce_time(value)
      return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
      Time.parse(value.to_s) rescue nil
    end

    def normalize_email(value)
      value&.downcase&.strip
    end

    # ---------- Convenience ----------

    def year
      square_created_at&.year
    end

    def present?
      id.present?
    end
  end
end