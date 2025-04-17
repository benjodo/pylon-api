# frozen_string_literal: true

module Pylon
  module Models
    class Base
      attr_reader :attributes, :_response

      def initialize(attributes = {}, response = nil)
        @attributes = attributes || {}
        @_response = response
      end

      def method_missing(method_name, *args, &block)
        key = method_name.to_s
        if @attributes.key?(key)
          @attributes[key]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @attributes.key?(method_name.to_s) || super
      end

      def [](key)
        @attributes[key.to_s]
      end

      def to_h
        @attributes
      end
      alias to_hash to_h

      def inspect
        "#<#{self.class.name} #{@attributes.inspect}>"
      end
    end
  end
end