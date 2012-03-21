class Fixnum
  def ljust_trim(length, padstr = ' ')
    self.to_s.ljust_trim(length, padstr)    
  end
end