# typed: true
require 'sorbet-runtime'

class LineItem
    extend T::Sig

    attr_reader :line_number, :item_number, :description, :quantity, :unit_price
    sig {params(line_number: Integer, item_number: String, description: String, quantity: Integer, unit_price: Float).returns(LineItem)}
    def initialize(line_number, item_number, description, quantity, unit_price)
        @line_number = line_number
        @item_number= item_number
        @description = description
        @quantity = quantity
        @unit_price  = unit_price
        self
    end

    def to_h
        {
            :line_number => "<Integer>#{@line_number}",
            :item_number => "<String>#{@item_number}",
            :description => "<String>#{@description}",
            :quantity => "<Integer> #{@quantity}",
            :unit_price  => "<Float>#{@unit_price}"
        }
    end
end