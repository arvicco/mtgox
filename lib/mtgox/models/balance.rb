require 'mtgox/models/model'

module MtGox
  module Models
    class Balance < Model
      prop :amount => :f,
           :currency => proc { |val| val.to_s.upcase }
    end
  end
end
