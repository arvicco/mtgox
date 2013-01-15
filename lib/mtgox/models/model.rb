module MtGox
  module Models

    # Base data Model class, in future it will be developed into ActiveModel
    class Model
      def self.prop *properties
        prop_hash = properties.last.is_a?(Hash) ? properties.pop : {}

        properties.each { |names| define_property names, '' }
        prop_hash.each { |names, type| define_property names, type }
      end

      def self.define_property names, type
        aliases = [names].flatten
        name = aliases.shift
        instance_eval do

          define_method(name) do
            @attributes[name]
          end

          case type
            when ''
              define_method("#{name}=") do |value|
                @attributes[name] = value
              end
            when Proc
              define_method("#{name}=") do |value|
                @attributes[name] = type.call(value)
              end
            else
              define_method("#{name}=") do |value|
                @attributes[name] = value.send "to_#{type}"
              end
          end

          aliases.each do |ali|
            alias_method "#{ali}", name
            alias_method "#{ali}=", "#{name}="
          end
        end
      end


      attr_reader :attributes

      def initialize attrs={}
        @attributes = {}
        set_attributes attrs
      end

      def set_attributes attrs={}
        attrs.keys.each { |key| self.send("#{key}=", attrs[key]) }
        self
      end

    end # class Model
  end # module Models
end
