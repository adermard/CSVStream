require "csvstream/version"
require 'csvstream/reader'
require 'csvstream/row'
require 'csvstream/column'

module CSVStream

	# TODO
	# Autoparse Columns to width of first row when not set
	# Embed ability to read in nil values in addition to empty values
	#   e.g. "" as Date is nil, no data for a field would be nil string and nil number fields
	#   I think the user switch for this would be treat no data as nil otherwise it would be empty string.
	#   "" should stil be considered emtpy string
	# Figure out better way to handle EOF than an exception
	# Figure out how to reduce the options everywhere mess

  class CSVStreamError < RuntimeError
  	attr_accessor :message
  	attr_accessor :line

  	def initialize(message = nil, line=nil)
  		@message = message
  		@line = line
  	end
  end

  class CSVStreamEOF < RuntimeError; end
  class RowError < CSVStreamError; end
  class ColumnOverflowError < CSVStreamError; end
  class ColumnUnderflowError < CSVStreamError; end

	class Stats
	  
	  def initialize()
	    @results = {}
	  end
	  #
	  # Stats is a free-form hash that contains info about how much was processed
	  def print
	    @results.keys.each do |k|
	      puts "#{k}: #{@results[k]}"
	    end
	  end
	  
	  def inc(str, amount=1)
	    @results[str] = (@results[str] || 0) + amount
	  end

	  def get(str)
	    @results[str] || 0
	  end
	  
	  def clear
	    @results = {}
	  end
	  
	end
end
