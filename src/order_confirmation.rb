require 'active_record'

class OrderConfirmation :: ActiveRecord::Base
    attr_reader :vendor_name, :confirmed_on, :order_number, :status, :po_number, :total, :line_items
    def initialize(confirmed_on, vendor_name, order_number, status, po_number, total, line_items)
        @vendor_name = vendor_name
        @confirmed_on = confirmed_on
        @order_number = order_number
        @status = status
        @po_number = po_number
        @total = total
        @line_items = line_items
    end
end