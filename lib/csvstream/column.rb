  
module CSVStream
  class Column
    attr_accessor :name
    attr_accessor :type
    attr_accessor :options

    def initialize(name, type = :string, options = {})
      @name = name
      @type = type
      @options = {quote: "'\""}.merge(options)
    end

    def self.set(columns, column_types, column_names, options = {})
      columns ||= []; column_names ||= []; column_types ||= []
      [column_types.length, column_names.length].max.times do |i|
        if columns[i].is_a?(Column)
          columns[i].name = column_names[i] if column_names[i]
          columns[i].type = column_types[i] if column_types[i]
          columns[i].options.merge!(options)
        else
          columns[i] = Column.new(column_names[i] || "Field #{i}", column_types[i] || :string, options)
        end
      end
      columns
    end

    def ==(n)
      self.name == n
    end

    def parse(str)
      str && self.send(@type, str)
    end

    def format(value)
      return "" unless value
      return self.send("#{@type}_fmt", value) if self.respond_to?("#{@type}_fmt")
      value.to_s
    end

    # DataTypes to parse

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

    # Write formats

    def self.default_format()
      "\"#{v}\""
    end

    def string_fmt(v)
      "\"#{v}\""
    end

    def date_fmt(v)
      "\"#{v}\""
    end

    def datetime_fmt(v)
      "\"#{v}\""
    end

    def method_missing(meth, *args, &block)
      raise "Unknown Type: You must extend the class to implement a #{meth} method to parse this type of object."
    end

  end
end
