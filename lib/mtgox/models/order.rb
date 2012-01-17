require 'mtgox/models/offer'

module MtGox
  module Models
    class Order < Offer
      prop :currency,
           :item,
           :type, #    1 for sell order or 2 for buy order
           :status, #  1 for active, 2 for not enough funds
           :dark,
           :priority,
           [:id, :oid] => :i, # Order ID
           :date => proc { |val| Time.at val } # 1326655184

    end
  end
end
