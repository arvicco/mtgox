require 'mtgox/models/offer'

module MtGox
  module Models
    class Order < Offer

      prop :currency,
           :item,
           :status, #  1 for active, 2 for not enough funds
           :real_status, #  "open" /
           :dark,
           :priority,
           [:id, :oid], # Order ID
           :type => proc { |val| val == 1 ? :sell : :buy }, # 1 for sell order or 2 for buy order
           [:date, :time] => proc { |val| Time.at val } # 1326655184

      def to_s
        "<Order: #{type} #{amount} #{item} at #{price} #{currency}/#{item}, " +
            "#{status}(#{real_status})>"
      end
    end
  end
end
