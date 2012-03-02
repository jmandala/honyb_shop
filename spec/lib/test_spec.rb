require 'spec_helper'

describe "nesting of before :each" do
  
  before :each do
    @time = Time.new
    puts @time
  end
  
  describe "one level down" do
    
    it "should put 1" do
      
    end
    
    it "should also put 1" do
      
    end
    
    describe "two levels down" do
      
      it "should still put 1!" do
        
      end
    end
  end
  
end