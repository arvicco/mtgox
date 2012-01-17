require 'mtgox/models/model'

module MtGox
  module Models
    class Depth < Model
      prop :buy,
           :sell,
           :currency,
           :item,
           [:vol, :volume] => :f,
           :volume_int => :i,
           :total_volume_int => :i,
           :price  => :f,
           :price_int  => :i,
           [:id, :now] => :i,
           [:type, :type_str]  => proc {|val| val == 1 || val == 'bid' ? :bid : :ask}
    end
  end
end
