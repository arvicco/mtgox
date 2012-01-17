require 'mtgox/models/offer'

module MtGox
  module Models
    class Bid < Offer

      def initialize(price=nil, amount=nil)
        super :price => price, :amount => amount
      end

      def eprice
        price * (1 - MtGox.commission)
      end

    end
  end
end
