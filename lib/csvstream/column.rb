  
module CSVStream
  class Column
    attr_accessor :name
    attr_accessor :type

    def initialize(name, type = :string, options = {})
      @name = name
      @type = type
      @options = {quote: "'\""}.merge(options)
    end

    def ==(n)
      self.name == n
    end

    def parse(str)
      str && self.send(@type, str)
    end

    def string(s)
      (s[0] && s[0] == s[-1] && @options[:quote].include?(s[0])) ? s[1, s.length - 2] : s
    end

    def integer(s)
      s.to_i
    end

    def float(s)
      s.to_f
    end
    
    def date(s)
      Date.parse(s)
    end

    def datetime(s)
      DateTime.parse(s)
    end

    def method_missing(m, s)
      raise "Unknown Type: You must extend the class to implement a #{m} method to parse this type of object."
    end

  end
end
