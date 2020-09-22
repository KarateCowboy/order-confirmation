require './src/order_confirmation'
require 'date'

describe OrderConfirmation do
    describe '#new' do
        it 'has a bunch of attributes' do
            august_tenth = DateTime.new 2014,8,10
            vendor_name = 'Maintenance-USA'
            order_number = '12345678'
            status = 'pending'
            po_number = '22551-1'
            total = 713.79
            line_items = ['one', 'two']
            new_order = OrderConfirmation.new august_tenth, vendor_name, order_number, status, po_number, total, line_items

            expect(new_order.confirmed_on).to eq(august_tenth)
            expect(new_order.vendor_name).to eq(vendor_name)
            expect(new_order.order_number).to eq(order_number)
            expect(new_order.status).to eq(status)
            expect(new_order.po_number).to eq(po_number)
            expect(new_order.total).to eq(total)
            expect(new_order.line_items).to eq(line_items)
        end
    end
    describe '#from_pdf' do
      it 'returns the needed data' do
      end
    end
end