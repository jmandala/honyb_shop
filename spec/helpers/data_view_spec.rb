require_relative '../spec_helper'

describe DataViewHelper do
  
  it 'should display a labeled pair' do
    output = helper.data_pair('field_name')
    output.gsub(/\s/, '').downcase.should == "<div class='data_pair field_name'><label><span class=\"translation_missing\" title=\"translationmissing:en.field_name\">field name</span></label></div>".gsub(/\s/, '')    
  end
  
  it 'should display a labeled pair with a value' do
    output = helper.data_pair('field_name') { 'value' }
    output.gsub(/\s/, '').downcase.should == "<div class='data_pair field_name'><label><span class=\"translation_missing\" title=\"translationmissing:en.field_name\">field name</span></label>value</div>".gsub(/\s/, '')    
  end
    
  it 'should allow a custom class name' do
    output = helper.data_pair('field_name', :class => 'the_class')
    output.gsub(/\s/, '').downcase.should == "<div class='data_pair the_class'><label><span class=\"translation_missing\" title=\"translationmissing:en.field_name\">field name</span></label></div>".gsub(/\s/, '')    
  end
  
  it 'should allow a custom label' do
    output = helper.data_pair('field_name', :label => 'the_label') { 'value' }
    output.gsub(/\s/, '').downcase.should == "<div class='data_pair field_name'><label>the_label</label>value</div>".gsub(/\s/, '')    
  end
  
end