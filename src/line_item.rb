require 'active_record'

class LineItem :: ActiveRecord::Base
    attr_reader :line_number, :item_number, :description, :quantity, :unit_price 
    def initialize(line_number, item_number, description, quantity, unit_price)
    @line_number = line_number
    @item_number= item_number
    @description = description
    @quantity = quantity
    @unit_price  = unit_price
    end
end