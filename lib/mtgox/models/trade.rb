require 'mtgox/models/offer'

module MtGox
  module Models
    class Trade < Offer

      prop :type, #        "trade"
           :item, #        "BTC"
           :price_currency, # "USD"
           :trade_type, #     "ask", "
           :primary, # "Y" or "N", the primary currency is always the buyers currency
           :properties, #  "limit,mixed_currency"
           :amount_int, # "1067215400"
           :price_int, #   681526"
           :amount => :f, #  10.672154
           :price => :f, #   6.81526
           [:id, :tid] => :i, #  "tid"=>"1326655184087854"
           [:date, :time] => proc { |val| Time.at val } # 1326655184

      def to_s with_date=nil
        (with_date ? "#{@date.strftime('%H:%M:%S')} " : '') +
            "<Trade: #{ amount.round(3) } at #{ price.round(3) }"+
            " #{price_currency}/#{item} (#{trade_type}) #{ properties } #{ primary } >"
      end

    end
  end
end
