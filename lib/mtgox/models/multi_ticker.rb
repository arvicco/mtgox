require 'mtgox/models/model'
require 'mtgox/price_ticker'

module MtGox
  module Models
    # Multi-currency Ticker
    class MultiTicker < Model
      include PriceTicker
      prop :currency,
           [:vol, :volume] => proc { |val| val['value'].to_f },
           [:last, :price] => proc { |val| val['value'].to_f },
           :last_local => proc { |val| val['value'].to_f },
           :last_orig => proc { |val| val['value'].to_f },
           :last_all => proc { |val| val['value'].to_f },
           :buy => proc { |val| val['value'].to_f },
           :sell => proc { |val| val['value'].to_f },
           :high => proc { |val| val['value'].to_f },
           :low => proc { |val| val['value'].to_f },
           :avg => proc { |val| val['value'].to_f },
           :vwap => proc { |val| val['value'].to_f }
    end
  end
end
