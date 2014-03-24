  
module CSVStream
  class Column
    attr_accessor :name
    attr_accessor :type
    attr_accessor :proc
    FUNCTIONS = {
      string: Proc.new {|s| (s[0] && s[0] == s[-1] && "'\"".include?(s[0])) ? s[1, s.length - 2] : s},
      number: Proc.new {|s| s.to_i},
      date: Proc.new {|s| Date.parse(s) },
      datetime: Proc.new {|s| DateTime.parse(s) }
    }

    def initialize(name, type = :string, options = {})
      @name = name
      @type = type
      @options = {quote: "'\""}.merge(options)
      @proc = FUNCTIONS[type]
    end

    def ==(n)
      self.name == n
    end

    # OLD
    
    def self.add_parser(type, proc)
      FUNCTIONS[type] = proc
    end

    def almost_parse(str)
      str && @proc.call(str)
    end

    def strip_quotes(s)
      quote = @options[:quote]
      (s[0] && s[0] == s[-1] && quote.include?(s[0])) ? s[1, s.length - 2] : s
    end

    # NEW

    def parse(str)
      str && self.send(@type, str)
    end

    def string(s)
      (s[0] && s[0] == s[-1] && @options[:quote].include?(s[0])) ? s[1, s.length - 2] : s
    end

    def number(s)
      s.to_i
    end

    def date(s)
      Date.parse(s)
    end

    def datetime(s)
      DateTime.parse(s)
    end

    def method_missing(m, s)
      raise "Unknown Type: #{m}"
    end
    
  end
end
