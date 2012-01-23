require 'mtgox/models/offer'

module MtGox
  module Models
    class Bid < Offer

      prop [:id, :stamp] => :i

      def initialize data
        data.is_a?(Hash) ? super(data) : super(:price => data[0], :amount => data[1])
      end

      def eprice
        price * (1 - MtGox.commission)
      end

      def real_time
        Time.at(id/1000000.0).strftime '%H:%M:%S.%3N' if id
      end

      def to_s
        "<#{real_time} Ask: #{price} #{ amount.round(3) }>"
      end

    end
  end
end
