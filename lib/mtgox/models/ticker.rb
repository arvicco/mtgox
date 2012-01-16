require 'mtgox/models/model'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  module Models
    class Ticker
      include Singleton
      include PriceTicker
      attr_accessor :buy, :sell, :high, :low, :volume, :vwap
    end
  end
end
