require 'mtgox/models/model'

module MtGox
  module Models
    class Offer < Model

      prop :amount => :f,
           :price => :f,
           :amount_int => :i, # "1067215400"
           :price_int => :i #   681526"
    end
  end
end
