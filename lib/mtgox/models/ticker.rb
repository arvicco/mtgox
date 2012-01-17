require 'mtgox/models/model'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  module Models
    class Ticker < Model
      include Singleton
      include PriceTicker
      prop :buy,
           :sell,
           :high,
           :low,
           [:vol, :volume],
           [:last, :price],
           :avg,
           :vwap

    end
  end
end
