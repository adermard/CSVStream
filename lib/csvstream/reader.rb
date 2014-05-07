module CSVStream

  class Reader

    attr_accessor :file
    attr_accessor :separator
    attr_accessor :columns
    attr_accessor :column_overflow
    attr_accessor :column_underflow
    attr_accessor :bad_lines
    attr_accessor :stats

    def initialize(options = {})
      @columns = []
      @options = {
        whitespace: " \t\r\n",
        eol: "\n",
        quote: "'\"",
        separator: ',',
        column_overflow: nil,
        column_underflow: nil,
        comment: '#'
      }.merge(options)
      @stats = Stats.new
      @fp = File.new(options[:file], 'r') if options[:file]
      @fp = StringIO.new(options[:string]) if options[:string]
      reset()
    end
    #
    # Dont stomp on column types that are already specified but get the names
    def read_columns
      raise CSVStreamError.new("Error: No active stream to read") unless @fp.respond_to?(:getc)
      header = Row.new(nil, @options)
      
      @columns = Column.set(@columns, nil, readline(), @options)
      @options[:column_overflow] = true if @options[:column_overflow].nil?
      @options[:column_underflow] = true if @options[:column_underflow].nil?
    end
    #
    # Dont stomp on prior columns data unless what is given here overrides
    def set_columns(column_types, column_names = [])
      @columns = Column.set(@columns, column_types, column_names, @options)
      @options[:column_overflow] = true if @options[:column_overflow].nil?
      @options[:column_underflow] = true if @options[:column_underflow].nil?
    end

    def reset(options = {})
      @stats.print
      # rewind the stream and reset the stats and such
      @fp.rewind
      @stats.clear()
      @bad_lines = []
      @columns = nil
      # merge in new options
      @options.merge(options)
    end
    #
    # Interate over the entire file
    def each
      row = Row.new(@columns, @options)
      while true do
        begin
          @stats.inc("Lines Processed")  
          row.parse(readline())
        rescue Exception => ex
          @bad_lines << ex.line if ex.respond_to?(:line)
          @stats.inc("Bad Lines")
        end
        yield row unless row.values.empty?
        break if @fp.eof?
      end
    end
    #
    # Get a single row from the stream at a time
    def row
      raise CSVStreamEOF.new("File EOF") if @fp.eof?
      @stats.inc("Lines Processed")
      row = Row.new(@columns, @options)
      begin 
        row.parse(readline())
      rescue CSVStreamError => ex
        @bad_lines << ex.line
        @stats.inc("Bad Lines")
        raise ex
      end
      row
    end

    #
    # Consume the entire stream and put the contents into an array
    # Oldest Style - for backward compatibility
    def consume(column_names = nil, column_types = nil)
      result = []

      if column_names
        set_columns(column_types, column_names) 
      else
        read_columns
      end

      while true
        begin
          @stats.inc("Lines Processed")
          result << row()
        rescue CSVStreamEOF => e
          break
        rescue CSVStreamError => ex
          puts "Error: #{ex.to_s}"
          @bad_lines << ex.line
          @stats.inc("Bad Lines")
        end
      end
      @stats.print
      result
    end

    # private

    # Return an array of tokens found on the line
    def readline
      c = ''
      skipable = @options[:comment] + @options[:whitespace] + @options[:eol]
      # skip whitespace and leading comment characters
      while !@fp.eof? && skipable.include?(c = @fp.getc.chr)
        @fp.readline if c == @options[:comment]
      end

      raise CSVStreamEOF if @fp.eof?

      tokens = []
      token = ''
      prev = nil
      quote_char = nil
      # read a bunch of characters until we hit an eol outside of quotes
      while !(quote_char.nil? && @options[:eol].include?(c))
        if c == quote_char
          quote_char = nil
          c = '' if prev == c
        elsif quote_char.nil? && @options[:quote].include?(c)
          quote_char = c
          c = '' if prev == c
        end

        if quote_char
          token += c
        elsif c == @options[:separator]
          tokens << token.strip
          token = ''
        elsif c == @options[:comment]
          # An unquoted comment in middle of a line? Discard rest of line and keep going.
          @fp.readline
          c = ''
        else
          token += c
        end
        # get out if we are at the end
        break if @fp.eof?
        # set the prev character compared and get the next character
        prev = c
        c = @fp.getc.chr
      end
      tokens << token.strip
      tokens
    end

  end
end
