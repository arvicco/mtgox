require 'mtgox/models/offer'

module MtGox
  module Models
    class Ask < Offer

      def initialize(price=nil, amount=nil)
        self.price = price.to_f
        self.amount = amount.to_f
      end

      def eprice
        price / (1 - MtGox.commission)
      end

    end
  end
end
