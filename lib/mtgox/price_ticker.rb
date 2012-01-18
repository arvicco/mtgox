module MtGox
  module PriceTicker

    def self.included host
      host.class_eval do
        prop :previous_price

        alias old_price= price=

        def price= val
          @attributes[:previous_price] = price.to_f
          send "old_price=", val
        end

        alias last= price=
      end
    end

    def up?
      price.to_f > previous_price.to_f
    end

    def down?
      price.to_f < previous_price.to_f
    end

    def changed?
      price.to_f != previous_price.to_f
    end

    def unchanged?
      !changed?
    end

    alias :unch? :unchanged?
  end
end
