# app/lib/rendezvous_square/normalized_item.rb

module RendezvousSquare
  class NormalizedItem
    attr_reader \
      :id,
      :created_at,
      :amount_cents,
      :currency,
      :state,
      :transaction_type,
      :reference_id,
      :email

    def initialize(
      id:,
      created_at:,
      amount_cents: 0,
      currency: "USD",
      state: nil,
      transaction_type:,
      reference_id: nil,
      email: nil
    )
      @id = id
      @created_at = created_at
      @amount_cents = amount_cents
      @currency = currency
      @state = state
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
          extract_amount_from_order_object(item)
        else
          extract_amount_from_other_object(item)
        end

      new(
        id: safe(item, :id),
        created_at: safe(item, :created_at),
        amount_cents: amount_cents,
        currency: currency,
        state: safe(item, :state),
        transaction_type: type.to_s,
        reference_id: safe(item, :reference_id),
        email: extract_email_object(item)
      )
    end

    def self.extract_amount_from_order_object(order)
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

    def self.extract_amount_from_order_hash(order)
      # 1. Preferred: total_money
      total = order[:total_money]
      if total
        return [total[:amount], total[:currency] || "USD"]
      end

      # 2. Fallback: net_amounts.total_money
      net = order[:net_amounts]
      if net[:total_money].present?
        tm = net[:total_money]
        return [tm[:amount], tm[:currency] || "USD"] if tm
      end

      # 3. Last resort: sum line items
      line_items = order[:line_items] || []
      sum = line_items.sum do |li|
        money = li[:total_money]
        money[:amount].to_i if money[:amount].present?
      end

      currency =
        line_items.first &&
        line_items.first.dig[:currency]

      [sum, currency || "USD"]
    end

    def self.extract_amount_from_other_object(item)
      money = safe(item, :amount_money)
      return [nil, "USD"] unless money

      [money.amount, money.currency || "USD"]
    end

    def self.extract_amount_from_other_hash(item)
      money = item[:amount_money]
      return [nil, "USD"] unless money

      [money[:amount], money[:currency] || "USD"]
    end

    def self.from_hash(item, type:)
      data = item.with_indifferent_access

      amount_cents, currency =
        if type.to_s == "order"
          extract_amount_from_order_hash(item)
        else
          extract_amount_from_other_hash(item)
        end

      new(
        id: data[:id],
        created_at: data[:created_at],
        amount_cents: amount,
        currency: currency,
        state: data[:state],
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