require 'mtgox/models/ask'
require 'mtgox/price_ticker'

module MtGox
  module Models
    class MinAsk < Ask
      include PriceTicker
    end
  end
end
