require 'mtgox/models/ask'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  module Models
    class MinAsk < Ask
      include Singleton
      include PriceTicker
    end
  end
end
