# frozen_string_literal: true

module Pylon
  module Models
    class Collection
      include Enumerable
      
      attr_reader :items, :_response
      
      def initialize(items = [], model_class = nil, response = nil)
        @items = items.map do |item|
          model_class ? model_class.new(item) : item
        end
        @_response = response
      end
      
      def each(&block)
        @items.each(&block)
      end
      
      def [](index)
        @items[index]
      end
      
      def size
        @items.size
      end
      alias length size
      
      def to_a
        @items
      end
      
      def inspect
        "#<#{self.class.name} items=#{@items.size}>"
      end
    end
  end
end