require 'pdf-reader'
require './src/order_confirmation'
require 'awesome_print'

class Main
  def self.run
    pdf_reader = nil
    PDF::Reader.open('./spec/sample_order_confirmation.pdf') do |reader|
      pdf_reader = reader
    end
    page = pdf_reader.pages.last
    order = OrderConfirmation.from_pdf(page)
    ap order.to_h
  end
end

Main.run

