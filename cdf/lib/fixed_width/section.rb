class FixedWidth
  class Section
    attr_accessor :definition, :optional, :singular
    attr_reader :name, :columns, :options

    def initialize(name, options={})
      @name     = name
      @options  = options
      @columns  = []
      @trap     = options[:trap]
      @optional = options[:optional] || false
      @singular = options[:singular] || false
    end

    def column(name, length, options={})
      if column_names_by_group(options[:group]).include?(name)
        raise FixedWidth::DuplicateColumnNameError.new("You have already defined a column named '#{name}' in the '#{options[:group].inspect}' group.")
      end
      if column_names_by_group(nil).include?(options[:group])
        raise FixedWidth::DuplicateGroupNameError.new("You have already defined a column named '#{options[:group]}'; you cannot have a group and column of the same name.")
      end
      if group_names.include?(name)
        raise FixedWidth::DuplicateGroupNameError.new("You have already defined a group named '#{name}'; you cannot have a group and column of the same name.")
      end

      col = Column.new(name, length, @options.merge(options))
      @columns << col
      col
    end

    def spacer(length, spacer=nil)
      options           = {}
      options[:padding] = spacer if spacer
      column(:spacer, length, options)
    end

    def trap(&block)
      @trap = block
    end

    def template(name)
      template = @definition.templates[name]
      raise ArgumentError.new("Template '#{name}' not found as a known template.") unless template
      @columns += template.columns
      # Section options should trump template options
      @options = template.options.merge(@options)
    end

    def format(data)
      @columns.map do |c|
        hash = c.group ? data[c.group] : data
        c.format(hash[c.name])
      end.join
    end

    def parse(line, line_number)
      row       = group_names.inject({}) {|h,g| h[g] = {}; h }

      cursor = 0
      @columns.each do |c|
        unless c.name == :spacer
          assignee         = c.group ? row[c.group] : row
          capture = line.mb_chars[cursor..cursor+c.length-1] || ''
          assignee[c.name] = c.parse(capture)
        end
        cursor += c.length
      end
      
      row[:__LINE_NUMBER__] = line_number

      row
    end

    def match(raw_line)
      raw_line.nil? ? false : @trap.call(raw_line)
    end

    def method_missing(method, *args)
      column(method, *args)
    end

    private

    def column_names_by_group(group)
      @columns.select{|c| c.group == group }.map(&:name) - [:spacer]
    end

    def group_names
      @columns.map(&:group).compact.uniq
    end
  end
end