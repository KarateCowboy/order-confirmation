# typed: false
require 'pdf-reader'
require 'date'
require './src/order_confirmation_pdf'

describe OrderConfirmationPdf do
  describe '#confirmed_on' do
    it 'returns the date it was confirmed on' do
      pdf_reader = nil
      PDF::Reader.open('./spec/sample_order_confirmation.pdf') do |reader| pdf_reader = reader end
      page = pdf_reader.pages.last
      date_returned = OrderConfirmationPdf.confirmed_on page
      dt = DateTime.new 2014,8,10
      expect(date_returned).to eq(dt)
    end
  end
end