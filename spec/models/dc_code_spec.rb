describe DcCode do
  
  it "should return the default" do
    DcCode.default.should == DcCode.find_by_po_dc_code(nil)
  end
  
end