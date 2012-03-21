class FixedWidth
  class Column
    DEFAULT_PADDING = ' ' unless Column.const_defined? :DEFAULT_PADDING
    DEFAULT_ALIGNMENT = :right unless Column.const_defined? :DEFAULT_ALIGNMENT
    DEFAULT_TRUNCATE = false unless Column.const_defined? :DEFAULT_TRUNCATE
    DEFAULT_FORMATTER = :to_s unless Column.const_defined? :DEFAULT_FORMATTER

    attr_reader :name, :length, :alignment, :padding, :truncate, :group

    def initialize(name, length, options={})
      assert_valid_options(options)
      @name = name
      @length = length
      @alignment = options[:align] || DEFAULT_ALIGNMENT
      @padding = options[:padding] || DEFAULT_PADDING
      @truncate = options[:truncate] || DEFAULT_TRUNCATE

      @group = options[:group]

      @parser = options[:parser]
      @parser = @parser.to_proc if @parser.is_a?(Symbol)

      @formatter = options[:formatter]
      @formatter ||= DEFAULT_FORMATTER
      @formatter = @formatter.to_proc if @formatter.is_a?(Symbol)

      @nil_blank = options[:nil_blank]
    end

    def parse(value)
      if @nil_blank && blank?(value)
        return nil
      elsif @parser
        @parser.call(value)
      else
        case @alignment
          when :right
            value.lstrip
          when :left
            value.rstrip
        end
      end
    rescue
      raise ParserError.new("The value '#{value}' could not be parsed: #{$!}")
    end

    def format(value)
      pad(
          validate_size(
              @formatter.call(value)
          )
      )
    end

    private
    BLANK_REGEX = /^\s*$/ unless Column.const_defined? :BLANK_REGEX

    def blank?(value)
      value =~ BLANK_REGEX
    end

    def pad(value)
      case @alignment
        when :left
          value.ljust(@length, @padding)
        when :right
          value.rjust(@length, @padding)
      end
    end

    def assert_valid_options(options)
      unless options[:align].nil? || [:left, :right].include?(options[:align])
        raise ArgumentError.new("Option :align only accepts :right (default) or :left")
      end
    end

    def validate_size(result)
      return result if result.length <= @length
      raise FixedWidth::FormattedStringExceedsLengthError.new(
                "The formatted value '#{result}' in column '#{@name}' exceeds the allowed length of #{@length} chararacters.") unless @truncate
      case @alignment
        when :right then
          result[-@length, @length]
        when :left then
          result[0, @length]
      end
    end
  end
end