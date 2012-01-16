require 'mtgox/models/model'

module MtGox
  module Models
    class Offer < Model

      attr_accessor :amount, :price
    end
  end
end
