require 'mtgox/models/model'
require 'mtgox/price_ticker'

module MtGox
  module Models
    class Ticker < Model
      prop :buy,
           :sell,
           :high,
           :low,
           :last_all,
           :last_local,
           :avg,
           :vwap,
           [:vol, :volume],
           [:price, :last] => :f

      include PriceTicker

    end
  end
end
