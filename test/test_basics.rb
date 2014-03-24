require_relative 'helper'
require "minitest/autorun"

class TestBasics < MiniTest::Unit::TestCase

	def test_basic_file()
		underflow = false
		results  = []
		f = CSVStream::Reader.new(:file => 'test/data/people.csv')
		f.read_columns
		f.each {|r| results << r.values }
		assert_equal 1, f.stats.get("Bad Lines")
		assert_equal '"Adam "Hats" DerMarderosian",100', f.bad_lines.first
	end

	def test_advanced_file()
		results  = []
		f = CSVStream::Reader.new(:file => 'test/data/advanced.csv')
		f.read_columns
		f.each {|r| results << r.values }
		assert_equal 0, f.stats.get("Bad Lines")
		assert_equal 3, f.stats.get("Lines Processed")
	end
    # Embedded quotes are treated as doubled up quote characters
    # Handle newlines inside of quoted strings
    # Handle separators inside of quoted strings
    # Handle empty fields
    def test_harder_file()
    	results  = []
	    data = '
	    	Year,Make,Model,Description,Price
			1997,Ford,E350,"ac, abs, moon",3000.00
			,,,,
			1999,Chevy,"Venture ""Extended Edition""","",4900.00
			1999,Chevy,"Venture ""Extended Edition, Very Large""",,5000.00
			1996,Jeep,Grand Cherokee,"MUST SELL!
			air, moon roof, loaded",4799.00
			'
		f = CSVStream::Reader.new(:string => data)
		f.read_columns
		begin
			while (r = f.row())
				results << r
			end
		rescue CSVStream::CSVStreamEOF => ex
		end
		assert results[1].values.none? {|v| v.length > 0}
		assert_equal 0, f.stats.get("Bad Lines")
		assert_equal 6, f.stats.get("Lines Processed")
	end

    # Handle last line ending in EOF
    # The last line does not require a CRLF at the end
    def test_end_with_eof()
    	results = []
    	data = 'Year,Make,Model,Description,Price
				1997,Ford,E350,"ac, abs, moon",3000.00'
		f = CSVStream::Reader.new(:string => data)
		f.read_columns
		begin
			while (r = f.row())
				results << r
			end
		rescue CSVStream::CSVStreamEOF => ex
		end
		assert_equal 0, f.stats.get("Bad Lines")
		assert_equal 1, f.stats.get("Lines Processed")
    end

    def test_too_many_columns
    	data = 'Year,Make,Model,Description,Price
				1997,Ford,E350,"Loaded",3000.00,"Blue"'
		f = CSVStream::Reader.new(:string => data, :column_overflow => false)
		f.read_columns
		r = f.row()
		
		assert_equal f.columns.count + 1, r.values.count
		assert_equal '"Blue"', r.values[f.columns.count]
    end

    # Spaces are part of the field only when they are inside of quotes, trim baby trim
    def test_trim_space
    end

end
