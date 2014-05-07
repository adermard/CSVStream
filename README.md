# CsvStream

CSVStream is a gem for reading and writing comma or other delimited data from an input stream.  Creation of this gem was inspired by the need for a csv parser that could handle quoted strings and convert column data into Ruby objects.  The Reader will accept an input stream from a file or string.  The Reader is as close to the "CSV Spec" as possible and will allow quoted strings to contain both field separators and line terminators.  Supports a standard set of datatypes (String, Integer, Float, Data, Datetime) and user-defined datatypes can be easily added to the Column object.  The Reader keeps an array of rows that failed to parse and statistics of how many rows processed and how many rows failed.

The writer is fairly straightforward but is not implemented yet.

## Installation

Add this line to your application's Gemfile:

    gem 'csvstream'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csvstream

## Usage

Simple Reader example code:

```ruby
f = CSVStream::Reader.new(file: "./data.csv")
f.read_columns
f.each {|line| puts line}
```

More Advanced Reader example:

```ruby
f = CSVStream::Reader.new(file: "./data.csv")
f.set_columns([:string, :number, :date, :string], ["Name", "Age", "Birthdate", "Moto"])

while still_working
	row = f.row()
	puts "#{row['Name']} - #{row['Moto']}" if (Time.now.to_date - row[1]) > 21.years
end
```


## Exceptions Thrown

CSVStream::CSVStreamEOF - EOF was reached and another row is requested.
CSVStream::RowError - failed to parse a row with the option :catastrophic_row_errors set to true
CSVStream::ColumnOverflowError - Too many columns present in the row parsed with the option :column_overflow set to true
CSVStream::ColumnUnderflowError - Not enough columns present in the row parsed with the option :column_underflow set to true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
