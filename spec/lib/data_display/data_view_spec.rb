require_relative '../../spec_helper'

describe DataDisplay::DataView do
  
  it 'should display a labeled pair' do

    output = DataDisplay::DataView.data_pair('field_name')
    output.gsub(/\s/, '').downcase.should == "<div class='field_name'><label>field_name</label></div>".gsub(/\s/, '')
       
  end
  
end