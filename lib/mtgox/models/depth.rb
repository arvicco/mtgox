require 'mtgox/models/model'

module MtGox
  module Models
    class Depth < Model
      prop :currency,
           :item,
           [:vol, :volume] => :f,
           :volume_int => :i,
           :total_volume_int => :i,
           :price => :f,
           :price_int => :i,
           [:id, :now] => :i,
           [:side, :type, :type_str] => proc { |val| val == 1 || val == 'bid' ? :bid : :ask }

      def real_time
        Time.at(id/1000000.0).strftime '%H:%M:%S.%3N'
      end

      def to_s
        "<#{real_time} Depth: #{type} #{ vol > 0 ? '+' : ''}#{ vol.round(2) } at #{ price.round(3) }" +
            " #{currency}/#{item} ##{id}>"
      end

    end
  end
end
