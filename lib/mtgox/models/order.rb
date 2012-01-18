require 'mtgox/models/offer'

module MtGox
  module Models
    class Order < Offer

       prop :currency,
           :item,
           :type, #    1 for sell order or 2 for buy order
           :status, #  1 for active, 2 for not enough funds
           :real_status, #  "open" /
           :dark,
           :priority,
           :amount_int => :i,
           :price_int => :i,
           [:id, :oid] => :i, # Order ID
           [:date, :time] => proc { |val| Time.at val } # 1326655184

    end
  end
end
