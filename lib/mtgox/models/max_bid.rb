require 'mtgox/models/bid'
require 'mtgox/price_ticker'

module MtGox
  module Models
    class MaxBid < Bid
      include PriceTicker
    end
  end
end
