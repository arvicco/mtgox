require 'mtgox/models/model'

module MtGox
  module Models
    class Balance < Model
      prop :amount => :f,
           :currency => proc { |val| val.to_s.upcase }

      def to_s
        "<Balance: #{ amount } #{currency}>"
      end

    end
  end
end
