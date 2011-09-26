require_relative '../../spec_helper'

describe DataDisplay::DataView do
  
  it 'should display a labeled pair' do
    output = DataDisplay::DataView.data_pair('field_name')
    output.gsub(/\s/, '').downcase.should == "<div class='field_name'><label>field_name</label></div>".gsub(/\s/, '')    
  end
  
  it 'should display a labeled pair with a value' do
    output = DataDisplay::DataView.data_pair('field_name') { 'value' }
    output.gsub(/\s/, '').downcase.should == "<div class='field_name'><label>field_name</label>value</div>".gsub(/\s/, '')    
  end
    
  it 'should allow a custom class name' do
    output = DataDisplay::DataView.data_pair('field_name', :class => 'the_class') { 'value' }
    output.gsub(/\s/, '').downcase.should == "<div class='the_class'><label>field_name</label>value</div>".gsub(/\s/, '')    
  end
  
  it 'should allow a custom label' do
    output = DataDisplay::DataView.data_pair('field_name', :label => 'the_label') { 'value' }
    output.gsub(/\s/, '').downcase.should == "<div class='field_name'><label>the_label</label>value</div>".gsub(/\s/, '')    
  end
  
end