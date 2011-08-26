require_relative '../spec_helper'

describe CdfImportExceptionLog do
  
  before(:each) do
    @error = StandardError.new("this is a new error")
    @log = CdfImportExceptionLog.create(:event => @error.message, :backtrace => @error.backtrace)
  end
  
  it "should save a backtrace" do
    @log.backtrace.should == @error.backtrace
  end

  it "should save an event" do
    @log.event.should == @error.message
  end
end
