module CSVStream 
  class Row
    attr_reader :columns
    attr_reader :values
    
    def initialize(columns, options = {})
      @columns = columns
      @options = options
      @values = []
    end
    #
    # only parse the columns we know about but leave the extras in the
    # return array of line parsed
    def parse(tokens)
      @values = tokens
      return @values if tokens.empty?

      raise ColumnOverflowError.new("Column Overflow: Too many columns found", tokens.join(',')) if @options[:column_overflow] && @values.length > @columns.length
      raise ColumnUnderflowError.new("Column Underflow: Not enough columns found: #{tokens.join(',')}", tokens.join(',')) if @options[:column_underflow] && @values.length < @columns.length

      @columns.each_with_index {|c, i| @values[i] = c.parse(tokens[i]) if tokens[i]}
      @values
    end
    #
    # Generic Accessor
    def [](n)
      n = @columns.index(n.to_s) unless n.is_a?(Integer)
      @values[n] rescue nil
    end

    def length
      @values.length
    end

    def to_hash
      Hash[@columns.collect(&:name).zip(@values)]
    end

  end

end
