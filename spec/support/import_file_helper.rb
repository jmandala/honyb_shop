class ImportFileHelper

  def self.should_match_date(object, record, field, fmt="%y%m%d")
    import_value = record[field]
    object_value = object.send(field)

    if import_value.to_i == 0
      return object_value.should == nil
    end

    object_value.strftime(fmt).should == Time.strptime(import_value, fmt).strftime(fmt)
  end

  def self.should_match_money(object, record, field)
    import_value = BigDecimal.new((record[field].to_f / 100).to_s, 0)
    object_value = object.read_attribute(field)
    if object_value != import_value
      puts "error on field: #{field}. Import value:'#{import_value.to_s}' != Object value:'#{object_value.to_s}'"
    end

    object_value.should == import_value

  end

  def self.should_match_text(object, record, field)
    value = object.read_attribute(field)
    if record[field].nil?
      value.should == '' || value.should == nil
    else

      if object.send(field) != record[field].strip
        puts "error on field: #{field}. '#{record[field]}' != '#{object.send(field)}'"
      end

      value.should == record[field].strip
    end
  end

  def self.should_match_i(object, record, field)
    if object.send(field) != record[field].strip.to_i
      puts "error on field: #{field}. '#{record[field]}' != '#{object.send(field)}'"
    end

    object.send(field).should == record[field].strip.to_i
  end

end
