require 'spec_helper'

describe "A PoaFile" do
  context "there are no POA files on the server" do
    it "should count remote POA files" do
      PoaFile.retrieve_count.should == []
    end
  end

  context "there are POA files on the server" do
    it "should retrieve POA files" do
      files = PoaFile.retrieve
      files.should_not == []
      files.size.should > 0

      #imported = PoaFile.import!
      #imported.size.should == files.size

    end
  end

end
