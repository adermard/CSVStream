module CSVStream

  class Writer

    attr_accessor :file
    attr_accessor :options
    attr_accessor :columns

    

  	def initialize(options)
  		 @options = {
        eol: "\n",
        quote: "\"",
        separator: ',',
        comment: '#'
      }.merge(options)
      @fp = File.new(options[:file], 'w') if options[:file]
      @columns = Column.set(nil, @options[:column_types], @options[:column_names], @options)
      @default_column = CSVStream::Column.new('default')
  	end

  	def write_columns(names = nil)
      output = ""
      @columns = Column.set(@columns, [], names, @options) if names
      @columns.each do |c|
        output << Column.string_fmt(c.name)
        output << (c.equal?(@columns.last) ? @options[:eol] : @options[:separator])
      end
      @fp.write(output)
  	end

    # Feed with arrays of elements or an array of arrays
  	def write(data)
      raise CSVStream::InsufficientDataError unless data.is_a?(Array)
	  	wrapper = data[0].is_a?(Array) ? data : [data]
  		wrapper.each {|r| write_row(r) }
  	end

    private

    def write_row(r)
      output = ""
      r.each_with_index.each do |v, i|
        output << (@columns[i] ? @columns[i].format(v) : @default_column.format(v))
        output << (i == (r.length - 1) ? @options[:eol] : @options[:separator])
      end
      @fp.write(output)
    end
	end
end
