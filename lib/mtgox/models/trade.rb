require 'mtgox/models/offer'

module MtGox
  module Models
    class Trade < Offer

      prop :type, #        "trade"
           :item, #        "BTC"
           :price_currency, # "USD"
           :primary, # "Y" or "N", the primary currency is always the buyers currency
           :properties, #  "limit,mixed_currency"
           :amount => :f, #  10.672154
           :price => :f, #   6.81526
           [:id, :tid] => :i, #  "tid"=>"1326655184087854"
           [:date, :time] => proc { |val| Time.at val }, # 1326655184
           [:side, :trade_type] => proc { |val| val == 'bid' ? :bid : :ask } #  "ask"

      def real_time
        Time.at(id/1000000.0).strftime '%H:%M:%S.%3N'
      end

      def to_s
        "<#{real_time} Trade: #{trade_type} #{ amount.round(3) } at #{ price.round(3) }"+
            " #{price_currency}/#{item} #{properties} #{primary} #{time.strftime '%H:%M:%S.%3N'} ##{id}>"
      end

    end
  end
end
