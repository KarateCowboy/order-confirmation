# typed: true
require 'sorbet-runtime'
require 'pdf-reader'
require 'date'

require './src/line_item'

class OrderConfirmation
  extend T::Sig

  attr_reader :vendor_name, :confirmed_on, :order_number, :status, :po_number, :total, :line_items

  sig do
    params(confirmed_on: DateTime,
           vendor_name: String,
           order_number: String,
           status: String,
           po_number: String,
           total: Float, line_items: T::Array[LineItem]).returns(OrderConfirmation)
  end
  def initialize(confirmed_on, vendor_name, order_number, status, po_number, total, line_items)
    @vendor_name = vendor_name
    @confirmed_on = confirmed_on
    @order_number = order_number
    @status = status
    @po_number = po_number
    @total = total
    @line_items = line_items
    self
  end

  sig {params(pdf_page: PDF::Reader::Page).returns(OrderConfirmation)}
  def self.from_pdf(pdf_page)
     parsed_order = self.parse_order(pdf_page)
     parsed_line_items = pdf_page.text.lines.filter{|l| self.is_line_item(l)}.map{|l| self.parse_line_item(l)}.map{|li| LineItem.new(
         li[:line_number].to_i,
         li[:item_number],
         li[:description],
         li[:quantity].to_i,
         li[:price].to_f)}


    date_arr = parsed_order[:confirmed_on_date].split('/').map{|i| i.to_i}
    time_arr = parsed_order[:confirmed_on_time].split(':').map{|i| i.to_i }
    confirmed = DateTime.new(date_arr[2] + 2000,date_arr[1],date_arr[0], time_arr[0], time_arr[1])
     OrderConfirmation.new(
         confirmed,
         parsed_order[:vendor_name],
         parsed_order[:order_number],
         parsed_order[:status].downcase,
         parsed_order[:po_number],
         parsed_order[:total].to_f,
         parsed_line_items
     )
  end

  sig { params(page_lines: T::Array[String]).returns(String) }
  def self.vendor_name(page_lines)
    title_index = page_lines.index { |l| l.match('ORDER DETAIL SUMMARY') }
    vendor_line = page_lines[title_index + 2]
    return vendor_line.strip
  end

  sig { params(line: String).returns(T::Boolean) }
  def self.is_line_item(line)
    reg = /[\s]+[0-9]+[\s]+[0-9]+[\s]+[\w|\s]+[0-9]+[\s]+[\d\.]+[\s]+[\d\.]+/
    return line.match(reg) ? true : false
  end

  sig { params(line: String).returns(Hash) }
  def self.parse_line_item(line)
    regexes = {
        :line_number => /^[\s]+[0-9]+[\s]+/,
        :item_number => /\A[0-9]+[\s]+/,
        :description => /^[A-Z\s]+[\s]+/,
        :quantity => /^[0-9]+[\s]+/,
        :price => /^[0-9|\.]+[\s]+/,
        :exact_amount => /^[\d\.]+/
    }
    line_item_data = {}
    regexes_arr = regexes.to_a

    parse_li = lambda do |finders, list|
      if finders.length == 0
        return
      end
      head, *tail = finders
      key = head[0]
      regex = head[1]
      raw_match =list.match(regex).to_s
      line_item_data[key] = raw_match.strip

      chomped_line =list.sub(raw_match,'')
      parse_li.call(tail,chomped_line )
    end
    parse_li.call(regexes_arr, line)
    line_item_data
  end

  sig { params(page: PDF::Reader::Page).returns(Hash) }
  def self.parse_order(page)
    line_match_sets = {
        :status => 'STATUS',
        :confirmed_on_date => 'DATE ENTERED',
        :confirmed_on_time => 'TIME ENTERED',
        :po_number => 'PURCHASE ORDER NUMBER',
        :order_number => 'ORDER NUMBER',
        :total => 'TOTAL LINES'
    }
    data_match_sets = {
        :status => /(PENDING)|(COMPLETE)|(CANCELED)/,
        :confirmed_on_date => /[\d]{2,2}\/[\d]{2,2}\/[\d]{2,2}/,
        :confirmed_on_time => /[\d]{2,2}:[\d]{2,2}/,
        :po_number => /[\d]+-[\d]+/,
        :order_number => /[0-9]{7,}/,
        :total => /[0-9]+\.[0-9]+/
    }
    page_lines = page.text.lines
    lines_sans_line_items = page_lines.filter { |l| !self.is_line_item(l) }

    data = {}

    search = lambda do |finders, list|
      head, *tail = list

      if finders.length == 0 || head == nil
        return
      end

      found = finders.find { |matcher| head.match(matcher[1]) }
      if found
        fkey = found[0]
        data[fkey] = head.match(data_match_sets[fkey]).to_s
        new_finders = finders.filter { |f| f[0] != fkey }
        search.call(new_finders, tail)
      else
        search.call(finders, tail)
      end
    end
    search.call(line_match_sets,lines_sans_line_items)
    data[:vendor_name] = self.vendor_name(page_lines)
    data
  end

  def to_h
    h = {
        :vendor_name => "<String>#{@vendor_name}",
        :confirmed_on => "<DateTime>#{@confirmed_on}",
        :order_number => "<String>#{@order_number}",
        :status => "<String>#{@status}",
        :po_number => "<String>#{@po_number}",
        :total => "<Float>#{@total}",
        :line_items => @line_items.map{|i| i.to_h }
    }
    h
  end

end