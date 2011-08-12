class ImportFileHelper

  def self.should_match_date(object, record, field, fmt="%y%m%d")
    import_value = record[field]
    object_value = object.send(field)

    if import_value.to_i == 0
      return object_value.should == nil
    end

    object_value.strftime(fmt).should == Time.strptime(import_value, fmt).strftime(fmt)
  end


  def self.should_match_text(object, record, field)
    raise ArgumentError, "#{field} should not be null" if record[field].nil?
    object.read_attribute(field).should == record[field].strip
  end

  def self.should_match_i(object, record, field)
    object.send(field).should == record[field].strip.to_i
  end

end
