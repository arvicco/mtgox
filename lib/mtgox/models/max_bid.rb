require 'mtgox/models/bid'
require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  module Models
    class MaxBid < Bid
      include Singleton
      include PriceTicker
    end
  end
end
