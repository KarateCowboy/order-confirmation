# typed: true
require './src/line_item'

f = { :line_number => 1 , :item_number => "105350", :description => "AMANA ELEC DRYER WHITE", :quantity => 1, :unit_price => 374.79 }

describe LineItem, type: :model do
    context 'attributes' do
        it 'has them' do
            new_line_item = LineItem.new f[:line_number], f[:item_number], f[:description], f[:quantity], f[:unit_price]
            expect(new_line_item.line_number).to eq(f[:line_number])
            expect(new_line_item.item_number).to eq(f[:item_number])
            expect(new_line_item.description).to eq(f[:description])
            expect(new_line_item.quantity).to eq(f[:quantity])
            expect(new_line_item.unit_price).to eq(f[:unit_price])
        end
    end
end