require_relative '../../spec_helper'

describe DataDisplay::DataView do
  
  it 'should display a labeled pair' do

    DataDisplay::DataView.data_pair('field_name', 'value')
        
"""
.file_name
  %label #{t 'file_name'}
  = link_to poa_file.file_name, admin_fulfillment_poa_file_path(poa_file)
"""    
    
  end
  
end