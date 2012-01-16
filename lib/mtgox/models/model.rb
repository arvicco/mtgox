module MtGox
  module Models

    # Base data Model class, in future it will be developed into ActiveModel
    class Model
      def initialize attrs={}
        set_attributes attrs
      end

      def set_attributes attrs={}
        attrs.keys.each { |key| self.send("#{key}=", attrs[key]) }
      end
    end # class Model
  end # module Models
end
