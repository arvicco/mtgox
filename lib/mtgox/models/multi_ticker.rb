require 'mtgox/models/model'
require 'mtgox/price_ticker'

module MtGox
  module Models
    # Multi-currency Ticker
    class MultiTicker < Model
      prop :currency,
           [:vol, :volume] => proc { |val| val['value'].to_f },
           [:price, :last] => proc { |val| val['value'].to_f },
           :last_local => proc { |val| val['value'].to_f },
           :last_orig => proc { |val| val['value'].to_f },
           :last_all => proc { |val| val['value'].to_f },
           :buy => proc { |val| val['value'].to_f },
           :sell => proc { |val| val['value'].to_f },
           :high => proc { |val| val['value'].to_f },
           :low => proc { |val| val['value'].to_f },
           :avg => proc { |val| val['value'].to_f },
           :vwap => proc { |val| val['value'].to_f }

      include PriceTicker

      def to_s
        "<MultiTicker: #{currency} vol #{ vol.round(2) } last #{ last.round(3) }"+
            " buy #{ buy.round(3) } sell #{ sell.round(3) } low #{ low.round(3) }"+
            " high #{ high.round(3) } avg #{ avg.round(3) } vwap #{ vwap.round(3) } >"
      end
    end
  end
end
