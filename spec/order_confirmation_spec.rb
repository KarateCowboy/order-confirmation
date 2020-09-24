# typed: true
require './src/order_confirmation'
require 'date'
require 'awesome_print'

f = {}
f[:august_tenth] = DateTime.new 2014, 8, 10,11,6
f[:vendor_name] = 'Maintenance-USA'
f[:order_number] = '12345678'
f[:status] = 'pending'
f[:po_number] = '22551-1'
f[:total] = 713.79
f[:line_items] = ['one', 'two']


describe OrderConfirmation do
  describe '#new' do
    it 'has a bunch of attributes' do
      new_order = OrderConfirmation.new f[:august_tenth], f[:vendor_name], f[:order_number], f[:status], f[:po_number], f[:total], f[:line_items]

      expect(new_order.confirmed_on).to eq(f[:august_tenth])
      expect(new_order.vendor_name).to eq(f[:vendor_name])
      expect(new_order.order_number).to eq(f[:order_number])
      expect(new_order.status).to eq(f[:status])
      expect(new_order.po_number).to eq(f[:po_number])
      expect(new_order.total).to eq(f[:total])
      expect(new_order.line_items).to eq(f[:line_items])
    end
  end
  context 'parsing pdf' do
    sample_text = <<-FOO
      CUSTOMER NAME : PURCHASING PLATFORM LLC          ORDER NUMBER : 12345678
      4000 EAST 134 STREET                             DATE ENTERED : 10/08/14
FOO

    pdf_reader = nil
    page = nil
    before do
      PDF::Reader.open('./spec/sample_order_confirmation.pdf') do |reader|
        pdf_reader = reader
      end
      page = pdf_reader.pages.last
    end

    describe '#is_line_item' do
      it 'accurately returns true or false' do
        line_item_text = "   1 105350        AMANA ELEC DRYER WHITE                1   374.7900     374.79"
        matches = OrderConfirmation.is_line_item line_item_text
        expect(matches).to eq(true)
        bad_line_item_text = "1 105350                        1   374.7900     374.79"
        expect(OrderConfirmation.is_line_item(bad_line_item_text)).to eq(false)
      end
    end

    describe '#parse_order' do
      it('returns a hash of data as strings') do
        d = OrderConfirmation.parse_order(page)
        expect(d[:order_number]).to eq('12345678')
        expect(d[:po_number]).to eq('22551-1')
        expect(d[:confirmed_on_date]).to eq('10/08/14')
        expect(d[:confirmed_on_time]).to eq('11:06')
        expect(d[:status]).to eq('PENDING')
        expect(d[:vendor_name]).to eq('MAINTENANCE U.S.A.')
        expect(d[:total]).to eq('713.79')
      end
    end
    describe '#parse_line_items' do
      it 'returns has representing the line item' do
        line_item_text = "   1 105350        AMANA ELEC DRYER WHITE                1   374.7900     374.79"
        expected_results = {
            :line_number => '1',
            :item_number => '105350',
            :description => 'AMANA ELEC DRYER WHITE',
            :quantity => '1',
            :price => '374.7900',
            :exact_amount => '374.79'
        }
        d = OrderConfirmation.parse_line_item(line_item_text)
        expect(d).to eq(expected_results)
      end
    end
    describe '#from_pdf' do
      it 'returns the correct stuff' do
        new_order = OrderConfirmation.from_pdf(page)
        expect(new_order.confirmed_on).to eq(f[:august_tenth])
        expect(new_order.order_number).to eq(f[:order_number])
        expect(new_order.status).to eq(f[:status])
        expect(new_order.po_number).to eq(f[:po_number])
        expect(new_order.total).to eq(f[:total])
        expect(new_order.line_items.first.unit_price).to eq(374.79)
        expect(new_order.line_items.last.unit_price).to eq(339.00)
      end
    end
  end
end