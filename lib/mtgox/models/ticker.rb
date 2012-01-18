require 'mtgox/models/model'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  module Models
    class Ticker < Model
      include Singleton
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
