require 'mtgox/models/model'

module MtGox
  module Models
    class Offer < Model

      prop :amount => :f,
           :price => :f
    end
  end
end
